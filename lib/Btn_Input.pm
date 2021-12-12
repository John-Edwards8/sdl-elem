package Btn_Input;

use strict;
use warnings;


use DDP;
use Rect;
use Input;
use base 'Rect';

## Start position  стартовые координаты объекта
my $START_X =  250;
my $START_Y =   85;

## Start color  стартовый цвет объекта
my $r =    0;
my $g =  255;
my $b =    0;


sub new {
	my( $btn_in ) =  @_;

	$btn_in  =  $btn_in->SUPER::new;

	$btn_in->set_color( $r, $g, $b );
	$btn_in->_start_position;

	return $btn_in;
}



sub _start_position {
	my( $btn_in ) =  @_;

	$btn_in->{ x } =  $START_X;
	$btn_in->{ y } =  $START_Y;
}


sub on_press {
	my( $btn, $h, $e ) =  @_;

	my $input =  Input->new;
	$input->{ parent } =  $btn->{ parent };
	
	# weaken $input->{ parent };
	my %x =  ( h => $input->{h} );

	$input->{data}   =  \%x;
	# $rect->{status} =  'Rect';

	$input->store;
	push $btn->{ parent }->{ children }->@*, $input;


	# my $app_surf =  
	# $sdlx_surface->blit( $dest, $src_rect, $dest_rect );
}


## Меняет цвет объекта-кнопки (если над ней курсор)
sub on_mouse_over {
	my( $btn_in ) =  @_;

	$btn_in->{ c }{ b } =  200;
}



## Возвращает объекту-кнопке её цвет (когда курсор с неё уходит)
sub on_mouse_out {
	my( $btn_in ) =  @_;

	$btn_in->{ c }{ b } =  0;
}



sub get_sb_coords { }
sub store {}



1;
