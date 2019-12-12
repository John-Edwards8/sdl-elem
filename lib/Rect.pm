package Rect;

# use strict;
# use warnings;


use Scalar::Util qw(weaken);
use SDL::Event;

use AppRect;
use Color;
use Shape;


use base 'Shape';


my $START_W =  50;
my $START_H =  30;

my $y_offset_n =  0;
my $x_offset   =  50;
my $y_offset   =  50;
sub new {
	if( ref $_[1] eq 'Schema::Result::Rect' ) {
		my( $rect, $db_rect ) =  @_;

		$rect =  $rect->new(
			$db_rect->x, $db_rect->y, $db_rect->w, $db_rect->h,
			Color->new( $db_rect->r, $db_rect->g, $db_rect->b, $db_rect->a ),
		);
		$rect->{ id } =  $db_rect->id;
		return $rect;
	}


	my( $rect, $x, $y, $w, $h, $c ) =  @_;

	$x //=  ($x_offset += 30);
	$y //=  $y_offset_n * 5  + ($y_offset +=  10);

	if( $x_offset > 600 ) {
		$x_offset =  40;
		$y_offset =  50;
		$y_offset_n++;
	}

	$rect =  $rect->SUPER::new();

	my %rect = (
		x      => $x,
		y      => $y,
		w      => $w // $START_W,
		h      => $h // $START_H,
		c      => $c // Color->new,
	);
	$rect->@{ keys %rect } =  values %rect;


	return $rect;
}



sub draw_black {
	my( $rect, $screen, $x, $y ) = @_;

	$screen //=  AppRect::SCREEN();
	$x //=  0;
	$y //=  0;

	$x += $rect->{ ox } // $rect->{ x };
	$y += $rect->{ oy } // $rect->{ y };


	$screen->draw_rect([
		$x,
		$y,
		$rect->{ ow } // $rect->{ w },
		$rect->{ oh } // $rect->{ h },
	],[ 0, 0, 0, 0 ]);
}



sub draw {
	my( $rect, $screen, $x, $y ) = @_;


	$screen //=  AppRect::SCREEN();
	$x //=  0;
	$y //=  0;

	$x += $rect->{ x };
	$y += $rect->{ y };

	$screen->draw_rect([
		$x,
		$y,
		$rect->{ w },
		$rect->{ h },
	],[
		255,0,0,255
	]);
	#circuit
	$screen->draw_rect([
		$x +1,
		$y +1,
		$rect->{ w }-2,
		$rect->{ h }-2,
	],[
		$rect->{ c }->get()
	]);

	#size_button
	$screen->draw_rect([
		$x + $rect->{ w } -15,
		$y + $rect->{ h } -10,
		15,
		10,
	],[
		33, 200, 150, 255
	]);


	$rect->SUPER::draw( $screen, $x, $y );
}


## Сохраняет состояние объекта для draw_black перед его следующей отрисовкой
sub save_draw_coord {
	my( $rect ) =  @_;

	$rect->SUPER::save_draw_coord;

	$rect->{ ow } =  $rect->{ w };
	$rect->{ oh } =  $rect->{ h };
}



sub mouse_target {
	my( $object, $x, $y ) =  @_;

	return $x >= $object->{ x }
		&& $x <= $object->{ x } + $object->{ w }
		&& $y >= $object->{ y }
		&& $y <= $object->{ y } + $object->{ h }
}



# Делает проверку, что объект $rect находится внутри квадрата x,y,w,h
sub is_inside {
	my( $rect, $x, $y, $w, $h ) =  @_;

	return $rect->{ x } > $x  &&  $rect->{ x } + $rect->{ w } < $x + $w
		&& $rect->{ y } > $y  &&  $rect->{ y } + $rect->{ h } < $y + $h;
}



## Запись в базу parent_id для объекта
sub parent_id {
	my( $rect, $id ) =  @_;

	Util::db()->resultset( 'Rect' )->search({
		id => $rect->{ id },
	})->first->update({ parent_id => $id });

	$rect->{ parent_id } =  $id;
}



#назначение родителя его же детям
sub load_parent_data {
	my( $rect ) =  @_;
	for my $child( $rect->{ children }->@* ) {
		$child->{ parent } =   $rect;
		weaken $child->{ parent };
	}
}



## Сохранение состояние объекта
sub save_state {
	my( $rect ) =  @_;


	$rect->{ start_x } =  $rect->{ x };
	$rect->{ start_y } =  $rect->{ y };

	$rect->{ start_c } =  $rect->{ c };
}



## Восстановление  состояния объекта
sub restore_state {
	my( $rect ) =  @_;

	$rect->{ c } =  delete $rect->{ start_c };
	delete $rect->@{qw/ start_x start_y /};
}


## Проверка условия, при котором возможно выполнить drop для объекта
## Проверка - находится ли объект над другим объектом(возвращает этот объект)
sub can_drop {
	my( $rect, $drop_x, $drop_y, $h ) =  @_;

	my( $group, $child );
	for my $s ( $h->{ app }{ children }->@* ) {
		$s != $rect   or next;
		my $curr =  $s->is_over( $drop_x, $drop_y )   or next;

		$group =  $s;
		$child =  $curr;
		# last;
		return $curr;
	}

}


## Проверяет, попали ли в группу выделения объекты
sub can_group {
	my( $group, $square ) = @_;

	if( $group->{ x } < $square->{ x }
		&&  $group->{ y } < $square->{ y }
		&&  $group->{ x } + $group->{ w } > $square->{ x } + $square->{ w }
		&&  $group->{ y } + $group->{ h } > $square->{ y } + $square->{ h } ) {

		return $group;
	}
	return 1;
}


## Пересчитывает размер группы(каждого объекта группы, который требует пересчёта)
sub resize_group {
	my( $parent ) =  @_;

	my @children =  $parent->{ children }->@*;
	$parent->calc_group_size( \@children );

	if( $parent->{ parent }{ id } ) {
		$parent->{ parent }->resize_group;
	}
}


## Пересчитывает размер группы в соответствии с её содержимым
sub calc_group_size {
	my( $group, $children ) =  @_;

	my $w =   0;
	my $h =  10;

	for my $s ( @$children ) {
		if( $s->{ radius } ) {
			my $r =  $s->{ radius };
			$s->move_to( 10 + $r * 2, $h + $r * 2 );
			if( $s->{ c }{ r } < 225 ) {
				$s->{ c }{ r } =  $group->{ c }{ r } + 30;
			}

			$h +=  $r * 2 + 10;
			$w  =  $r * 2 > $w ? $r * 2 : $w;
		}
		else {
			$s->move_to( 10, $h );
			$s->{ c }{ r } =  $group->{ c }{ r } + 80;

			$h +=  $s->{ h } +10;
			$w  =  $s->{ w } > $w ? $s->{ w } : $w;
		}
	}

	$group->{ w } =  $w + 20;
	if( $group->{ w } < 50 ) {
		$group->{ w } =  50;
	}

	$group->{ h } =  $h;
	if( $group->{ h } < 30 ) {
		$group->{ h } =  30;
	}
}



sub get_points {
	my( $rect ) =  @_;

	return
		[ $rect->{ x }              , $rect->{ y }               ],
		[ $rect->{ x } +$rect->{ w }, $rect->{ y }               ],
		[ $rect->{ x }              , $rect->{ y } +$rect->{ h } ],
		[ $rect->{ x } +$rect->{ w }, $rect->{ y } +$rect->{ h } ],
	;
}



sub clip {
	my( $rect, $w, $h ) =  @_;

	if( my $p =  $rect->{ parent } ) {
		$w //=  $p->{ w };
		$h //=  $p->{ h };
	}

	if( $rect->{ x } < 0 ) {
		$rect->{ x } = 0;
	}
	if( $rect->{ y } < 0 ) {
		$rect->{ y } = 0;
	}

	if( $w  &&  $rect->{ x } > $w - $rect->{ w } ) {
		$rect->{ x } = $w - $rect->{ w };
	}
	if( $h  &&  $rect->{ y } > $h - $rect->{ h } ) {
		$rect->{ y } = $h - $rect->{ h };
	}
}



## Удаляет объект(пришедший в функцию) из числа детей его родителя
sub child_destroy {
	my( $square ) = @_;

	Util::db()->resultset( 'Rect' )->search({
		id => $square->{ id }
	})->delete;

	if( $square->{ children }->@* ) {

		for my $child ( $square->{ children }->@* ) {
			$child->child_destroy;
		}
	}
}


## Проверяет находится ли курсор над полем для изменения размеров объекта
sub is_over_res_field {
	my( $rect, $x, $y ) =  @_;

	return $x > $rect->{ x } + $rect->{ w } - 15
		&& $x < $rect->{ x } + $rect->{ w }
		&& $y > $rect->{ y } + $rect->{ h } - 10
		&& $y < $rect->{ y } + $rect->{ h }
}



## Изменяет цвет объекта при изменении его размеров(запоминает исходный цвет)
sub resize_color {
	my( $rect ) =  @_;

	if( !$rect->{ start_c } ) {
		$rect->{ start_c  } =  $rect->{ c };
		$rect->{ c } =  Color->new( 0, 200, 0 );
	}
}


## Изменяет размер объекта в соответсвии с координатами курсора
sub resize_to {
	my( $rect, $x, $y ) =  @_;

	$rect->{ w } =  $x - $rect->{ x };
	if( $x - $rect->{ x } < 50 ) {
		$rect->{ w } =  50;
	}

	$rect->{ h } =  $y - $rect->{ y };
	if( $y - $rect->{ y } < 30 ) {
		$rect->{ h } =  30;
	}


	$rect->{ children } or return;

	my $h, $w;
	for my $square( $rect->{ children }->@* ) {
		if( !$square->{ h }  &&  !$square->{ w } ) {
			$square->{ h } =  $square->{ radius } * 2;
			$square->{ w } =  $square->{ radius } * 2;
		}

		my $hi = $square->{ h } + $square->{ y } + 10;
		$h =  $hi > $h ? $hi : $h;
		my $wi = $square->{ w } + $square->{ x } + 10;
		$w =  $wi > $w ? $wi : $w;

		if( $square->{ radius } ) {
			delete $square->{ h };
			delete $square->{ w };
		}
	}
	$rect->{ h } = $rect->{ h } < $h ? $h: $rect->{ h };
	$rect->{ w } = $rect->{ w } < $w ? $w: $rect->{ w };
}



## Меняет цвет объекта, над которым курсор
sub on_mouse_over {
	my( $rect ) =  @_;

	$rect->{ c }{ r } =  200;

	# if( over_resize ) {
	#    $rect->on_resize
	#}
}

# sub on_resize {
# 	resize_enable( ... )
# }


# sub on_move {
# 	if( { is_resize } ) {
# 		resize_rectangle( ... )
#   }
# }


## Возвращает цвет объекту, над которым был курсор
sub on_mouse_out {
	my( $rect ) =  @_;

	$rect->{ c }{ r } =  23;
}



sub on_press {
	my( $shape, $h, $e ) =  @_;

}


# sub on_keydown {
# 	my( $rect, $h, $e ) =  @_;

# 	$h->{ app }{ event_state }{ SDLK_d() }
# 		or return;


# 	if( $rect->{ my_d } ) {
# 		delete $rect->{ my_d };
# 	}
# 	else {
# 		$rect->{ my_d } =  1;
# 	}

# 	printf "MY D: %s\n", $rect->{ my_d };
# }



1;
