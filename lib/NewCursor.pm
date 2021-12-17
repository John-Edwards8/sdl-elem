package NewCursor;

use strict;
use warnings;

use SDLx::Text;

use AppRect;
use Color;
use base 'Rect';

use SDL::Event;


sub _blink_timer {
	my $event =  SDL::Event->new();
	$event->type( SDL_USEREVENT );
	$event->user_code( 11 );
	$event->user_data1( 'hello event' );

	SDL::Events::push_event($event);

	return 1;
};

## Включает свойство hint (по событию USEREVENT )
sub _on_blink {
	my( $e, $app, $obj ) =  @_;

	$e->type == SDL_USEREVENT  &&  $e->user_code == 11
		or return;

	$obj->{ timer_tick } +=  1;
	$obj->{ c }{ r } =  $obj->{ timer_tick } % 255;
}


my $BLINK_TIMER =  250;
sub new {
	my( $obj ) =  shift;

	$obj =  $obj->SUPER::new( @_ );

	$obj->set_color( 255, 0, 0, 255 );

	$obj->{ timer_id } =  SDL::Time::add_timer( $BLINK_TIMER, 'Cursor::_blink_timer' );
	AppRect::SCREEN()->add_event_handler( sub{ _on_blink( @_, $obj ) } );

	# DB::x;

	return $obj;
}



sub on_keydown {
	my( $obj, $h, $e ) =  @_;

	# DB::x;

	$obj->{ x } +=  100;
}

sub draw{
	my( $obj ) =  shift;

	# DB::x;

	$obj->SUPER::draw( @_ );

	
}


1;
