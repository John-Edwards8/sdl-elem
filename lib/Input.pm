package Input;

use strict;
use warnings;

use SDLx::Text;
use SDLx::Surface;
use SDL::Events;
use SDL::Video;

use base 'Rect';
use Cursor;
use Variable;

my $r =  255;
my $g =  255;
my $b =  255;
my $a =  255;
my $map = {
	a => \&add_sym,
	b => \&add_sym,
	c => \&add_sym,
	d => \&add_sym,
	e => \&add_sym,
	f => \&add_sym,
	g => \&add_sym,
	h => \&add_sym,
	i => \&add_sym,
	j => \&add_sym,
	h => \&add_sym,
	k => \&add_sym,
	l => \&add_sym,
	m => \&add_sym,
	n => \&add_sym,
	o => \&add_sym,
	p => \&add_sym,
	q => \&add_sym,
	r => \&add_sym,
	s => \&add_sym,
	t => \&add_sym,
	u => \&add_sym,
	v => \&add_sym,
	w => \&add_sym,
	x => \&add_sym,
	y => \&add_sym,
	z => \&add_sym,
	space         => \&add_sym,
	backspace     => \&del_sym,
	"left ctrl"   => sub{},
	"right ctrl"  => sub{},
	"caps lock"   => sub{},
	"left shift"  => sub{},
	"right shift" => sub{},
	"left alt"    => sub{},
	"right alt"   => sub{},
	"left"     => \&cursor,
	"right"    => \&cursor,

};

# sub combinations{
# 	my( $e ) =  @_;

# 	SDL::Events::pump_events;
 
# 	my $letter    =  SDL::Events::get_key_name( $e->key_sym );


# 	if( $e->key_sym == SDLK_c() ){
#         SDL_SetClipboardText(  );
#     }
#     if( $e->key_sym == SDLK_v() ){
#         return SDL_GetClipboardText();
#     }
# }


sub cursor {
	my( $if, $e ) =  @_;

	if( $e->key_sym == SDLK_LEFT() ){
		$if->{ pos } -= 1;
	}
	if( $e->key_sym == SDLK_RIGHT() ){
		$if->{ pos } += 1;
	}
}

sub add_sym{
	my( $if, $e ) =  @_;

	if( length ( SDL::Events::get_key_name( $e->key_sym ) ) == 1 ){
		my $l =  modify( $e );

		$l ne ""   or return;

		splice $if->{ text }->@*, $if->{ text }->@*, 0, $l;
	}elsif( SDL::Events::get_key_name( $e->key_sym ) eq 'space' ){
		splice $if->{ text }->@*, $if->{ text }->@*, 0, ' ';
	}

}

sub del_sym{
	my( $if ) =  shift;

	splice( $if->{ text }->@*, -1, 1 );
}

sub modify{
	my( $e ) =  @_;

	SDL::Events::pump_events;
 
	my $mod_state =  SDL::Events::get_mod_state();
	my $letter    =  SDL::Events::get_key_name( $e->key_sym );

	if( $mod_state & KMOD_CTRL ){
		# \&combinations( $e );

		return "";
	}

	$mod_state & KMOD_SHIFT   or return $letter;
	return uc $letter;
}

# sub pos_corection{
# 	my( $if ) =  @_;

# 	my $e =  SDL::Event->new();
# 	SDL::Events::pump_events();
# 	SDL::Events::push_event($e);
# 	SDL::Events::poll_event($e);

# 	# DB::x   if scalar $if->{text}->@* % 5 == 0;

# 	if( $e->type == SDL_KEYDOWN() ){
# 		if( ( scalar $if->{text}->@* ) % 5 == 0 ){
# 			$if->{ pos } += 3;
# 		}
# 	}
	
# }


sub new_text{
	my( $if ) =  @_;

	# &pos_corection( $if );

	my $val =  join '', $if->{ text }->@*;

	return SDLx::Text->new(
			color 	=> [ 255, 0, 0 ],
			size  	=> 16,
			h_align => 'left',
			text  	=> $val ."",
	);
}

sub new {
	my( $input, $shape ) =  (shift, shift);

	my $if  =  $input->SUPER::new(@_);

	$if->{status}     =  'service';
	$if->{cursor_pos} =  0;
	$if->{h}          =  30;
	$if->{w}          =  70;
	$if->{x}          =  200;
	$if->{y}          =  200;
	$if->{highlight}  =  Color->new( 0, 0, 255, 255 );

	$if->set_color( $r, $g, $b, $a );

	return $if;
}


sub draw {
	my( $if, $dx, $dy ) =  @_;
	$dx ||= 0;
	$dy ||= 0;


	$if->SUPER::draw();

	$if->{ text }   or return;

	my $message =  &new_text( $if );
 	my $virt =  SDLx::Surface->display( width => 400, height => 200, flags=> SDL_HWSURFACE, depth=>32);
	# my $virt =  SDLx::Surface->new( width=> 400, height=>200, flags=> SDL_SWSURFACE, depth=>32 );
	my $screen =  AppRect::SCREEN();

	$message->write_xy( $virt, 0, 600 );

	# DB::x;

	$virt->blit( $screen, 
		SDL::Rect->new( 0 + $if->{ pos }*8,      600, $if->{w}, $if->{h} ),
		SDL::Rect->new( $if->{x}, $if->{y}, $if->{w}, $if->{h} ),
	);


	# my $x =  $if->{x} + $dx;
	# my $y =  $if->{y} + $dy;

	# my $Y =  $y + 5;
	# my $X =  0;

	# my $surf = SDLx::Surface->display( width => 1200, height => $if->{h});
	# $surf->draw_rect( [ $X, $Y, 1200, $if->{h}-4 ], [ 0, 0, 0, 0 ] );

	# my $surface = SDLx::Surface->display( width => $if->{w}, height => $if->{h});
	# $surface->draw_rect( [ $x, $y, $if->{w}-4, $if->{h}-4 ], [ 255, 255, 255, 255 ] );

	# # SDL::Video::set_clip_rect( $surface, SDL::Rect->new( $x, $y, $if->{w}-4, $if->{h}-4) );
}

## sub on_press {
# 	my( $if, $h, $e ) =  @_;

# 	# DB::x;

# 	my $x =  $if->{ x } + 10;
# 	$if->{ cursor } =  Cursor->new( $if->{x}+10, $if->{y}, 4, $if->{h} );

# 	# $h->{ app }->refresh_over( $e->motion_x, $e->motion_y );
# }

sub on_keydown {
	my( $if, $h, $e ) =  @_;

	$map->{ SDL::Events::get_key_name( $e->key_sym ) }->( $if, $e );

}


sub store { }
# sub on_mouse_over { }
# sub on_mouse_out { }
# sub on_move { }
sub get_sb_coords { }

1;
