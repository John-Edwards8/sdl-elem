package Btn_del;

use Rect;
use base 'Rect';

my $START_X =  250;
my $START_Y =    0;


sub new {
	my( $btn_del ) =  @_;

	$btn_del  =  $btn_del->SUPER::new;
	$btn_del->{ c } =   Color->new( 255,0,0 );

	$btn_del->set_start_position;

	return $btn_del;
}



sub set_start_position {
	my( $btn_del ) =  @_;

	$btn_del->{ x } =  $START_X;
	$btn_del->{ y } =  $START_Y;
}



sub draw {
	my( $app_rect, $app, $x, $y ) =  @_;

	$x //=  0;
	$y //=  0;

	$x += $app_rect->{ x };
	$y += $app_rect->{ y };

	$app->draw_rect([
		$x,
		$y,
		$app_rect->{ w },
		$app_rect->{ h },
	],[
		255,255,255,255
	]);
	#circuit
	$app->draw_rect([
		$x +1,
		$y +1,
		$app_rect->{ w }-2,
		$app_rect->{ h }-2,
	],[
		$app_rect->{ c }->get()
	]);
}



## delete all shapes or any one
sub moving_off {
	my( $btn_del, $app_rect, $e ) =  @_;

		$btn_del->start_position;

	## Удаление всех объектов
	if( $app_rect->{ btn }->is_over( $e->motion_x, $e->motion_y ) ) {
		$app_rect->{ children } =  ();
		Util::db()->resultset( 'Rect' )->delete;
		$app_rect->draw_black;

		return;
	}


	## Удаление одного объекта (группы)
	for my $shape( $app_rect->{ children }->@* ) {
		my $x;
		if( $shape->is_over( $e->motion_x, $e->motion_y ) ) {
			$x =  $shape;
			$shape->draw_black;
		}

		if( $x ) {
			$x->child_destroy;#удаление из базы по id
		}

		$app_rect->{ children }->@* =  grep{ $_ != $x } $app_rect->{ children }->@*;
	}
}


## Возвращение кнопки на стартовую позицию
sub start_position {
	my( $btn_del ) =  @_;

	$btn_del->restore_state;
	$btn_del->draw_black;
	$btn_del->set_start_position;
}



sub store {}



sub on_over {}



1;
