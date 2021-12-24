package Input;

use strict;
use warnings;

use SDLx::Text;
use SDLx::Surface;
use SDL::Events;
use SDL::Video;

use base 'Rect';
# use Cursor;
use NewCursor;
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
	1 => \&add_sym,
	2 => \&add_sym,
	3 => \&add_sym,
	4 => \&add_sym,
	5 => \&add_sym,
	6 => \&add_sym,
	7 => \&add_sym,
	8 => \&add_sym,
	9 => \&add_sym,
	0 => \&add_sym,
	"+" => \&add_sym,
	"," => \&add_sym,
	"/" => \&add_sym,
	"'" => \&add_sym,
	"[" => \&add_sym,
	"]" => \&add_sym,
	"=" => \&add_sym,
	"-" => \&add_sym,
	'`' => \&add_sym,
	"." => \&add_sym,
	";" => \&add_sym,
	":" => \&add_sym,
	'"' => \&add_sym,
	"{" => \&add_sym,
	"}" => \&add_sym,
	"*" => \&add_sym,
	"'\'" => \&add_sym,
	"escape"      => \&add_sym,
	"space"       => \&add_sym,
	"tab"         => \&add_sym,
	"backspace"   => \&del_sym,
	"left ctrl"   => sub{},
	"right ctrl"  => sub{},
	"caps lock"   => sub{},
	"left shift"  => \&modify,
	"right shift" => \&modify,
	"left alt"    => sub{},
	"right alt"   => sub{},
	"left"        => \&navigation,
	"right"       => \&navigation,
	"[1]" => \&numpad,
	"[2]" => \&numpad,
	"[3]" => \&numpad,
	"[4]" => \&numpad,
	"[5]" => \&numpad,
	"[6]" => \&numpad,
	"[7]" => \&numpad,
	"[8]" => \&numpad,
	"[9]" => \&numpad,
	"[0]" => \&numpad,
	"[+]" => \&numpad,
	"[/]" => \&numpad,
	"[-]" => \&numpad,
	"[*]" => \&numpad,
	"[.]" => \&numpad,

};

my $shmap = {
	1 => "!",
	2 => "@",
	3 => "#",
	4 => "\$",
	5 => "%",
	6 => "^",
	7 => "&",
	8 => "*",
	9 => "(",
	0 => ")",
	"-" => "_",
	"=" => "+",
	"[" => "{",
	"]" => "}",
	"," => "<",
	"." => ">",
	"/" => "?",
	";" => ":",
	'`' => "~",
	"'" => '"',
};

# sub combinations{
# 	my( $e ) =  @_;

# 	SDL::Events::pump_events;
 
# 	my $letter    =  SDL::Events::get_key_name( $e->key_sym );

# # 	if( $e->key_sym == SDLK_c() ){
# #         SDL_SetClipboardText(  );
# #     }
# #     if( $e->key_sym == SDLK_v() ){
# #         return SDL_GetClipboardText();
# #     }
# }

sub numpad{
	my( $if, $e ) =  @_;

	DB::x;

	my $l =	SDL::Events::get_key_name( $e->key_sym );

	my  @elems =  split( //, $l );
	pop( @elems );
	shift( @elems );

	splice $if->{ text }->@*, $if->{ text }->@*, 0, join( '', @elems );
}


sub navigation {
	my( $if, $e ) =  @_;

	if( $e->key_sym == SDLK_LEFT() ){
		$if->{ pos } > 0  or return;
		$if->{ pos } <= (scalar $if->{ text }->@* % 5)   or return;
		$if->{ pos } += 1;
	}
	if( $e->key_sym == SDLK_RIGHT() ){
		$if->{ pos } > 0   or return;
		$if->{ pos } -= 1;
	}
}

sub add_sym{
	my( $if, $e ) =  @_;

	if( length ( SDL::Events::get_key_name( $e->key_sym ) ) == 1 ){
		my $l =  modify( $if, $e );

		$l ne ""   or return;

		splice $if->{ text }->@*, $if->{ text }->@*, 0, $l;
	}elsif( $e->key_sym == SDLK_SPACE ){
		splice $if->{ text }->@*, $if->{ text }->@*, 0, ' ';
	}elsif( $e->key_sym == SDLK_TAB ){
		splice $if->{ text }->@*, $if->{ text }->@*, 0, '    ';
	}elsif( $e->key_sym == SDLK_ESCAPE ){
		exit;
	}

	$if->{ct} += 1;

}

sub del_sym{
	my( $if, $e ) =  @_;

	if( $e->key_sym == SDLK_BACKSPACE ){
		$if->{ text }->@* > 0   or return;
		splice( $if->{ text }->@*, -1, 1 );

		$if->{ pos } >= 0   or return;
		$if->{ pos } -= 1;		
	}
}

sub modify{
	my( $if, $e ) =  @_;
 
	my $mod_state =  SDL::Events::get_mod_state();
	my $letter    =  SDL::Events::get_key_name( $e->key_sym );



	if( $mod_state & KMOD_CTRL ){
		# \&combinations( $e );

		return "";
	}
	if( $mod_state & KMOD_CAPS ){

		$mod_state & KMOD_SHIFT   or return uc $letter;
		return $letter;
	}
	if(	$mod_state & KMOD_SHIFT  &&  $shmap->{ $letter } ){

		return $shmap->{ $letter };
	}
	if(	$mod_state & KMOD_SHIFT ){
		return uc $letter;	
	}
	return $letter
}

sub pos_corection{
	my( $if, $e ) =  @_;

	$e->type & SDL_KEYUP   or return;
	$e->key_sym != SDLK_BACKSPACE   or return;
	$e->key_sym != SDLK_DELETE   or return;
	# DB::x;
	if( scalar $if->{ct}  % 5 == 0 ){
		$if->{ pos } += 4;
	}
	
}


sub new_text{
	my( $if, $e ) =  @_;

	defined( $if->{ text } )  or return;

	&pos_corection( @_ );

	my $val   =  join '', $if->{ text }->@*;

	return SDLx::Text->new(
			color 	=> [ 0, 0, 0 ],
			size  	=> 16,
			h_align => 'left',
			text  	=> $val ."",
	);
}

sub new {
	my( $input, $shape ) =  (shift, shift);

	my $if  =  $input->SUPER::new(@_);

	$if->{status}     =  'service';
	$if->{ct}		  =  0;
	$if->{cursor_pos} =  0;
	$if->{pos}        =  0;
	$if->{h}          =  30;
	$if->{w}          =  70;
	$if->{x}          =  200;
	$if->{y}          =  200;
	# $if->{highlight}  =  Color->new( 0, 0, 255, 255 );

	$if->set_color( $r, $g, $b, $a );

	return $if;
}


sub draw {
	my( $if, $dx, $dy ) =  @_;
	$dx ||= 0;
	$dy ||= 0;

	my $surface = SDLx::Surface->display( width => $if->{w}, height => $if->{h});
	$surface->draw_rect( [ $if->{x}, $if->{y}, $if->{w}-4, $if->{h}-4 ], [ 255, 255, 255, 255 ] );

	$if->SUPER::propagate( "draw", $if );

	$if->{ message }   or return;

	my $x = $if->{x} + 2 - $if->{ pos }*8;
	my $y = $if->{y} + 5;

	DB::x   if  scalar $if->{ct}  % 5 == 0;

	my $message =  $if->{ message };
 	# my $virt =  SDLx::Surface->display( width => 400, height => 200, flags=> SDL_HWSURFACE, depth=>32);
	# my $virt =  SDLx::Surface->new( width=> 400, height=>200, flags=> SDL_SWSURFACE, depth=>32 );
	# my $screen =  AppRect::SCREEN();
	
	$message->write_xy( $surface, $x, $y );

	# DB::x;

	# $surface->blit( $screen, 
	# 	SDL::Rect->new( $x, $y, $if->{w}, $if->{h}+2 ),
	# 	SDL::Rect->new( $if->{x}, $if->{y}-2, $if->{w}, $if->{h} ),
	# );


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

# # sub on_press {
# # my( $if, $h, $e ) =  @_;
# # DB::x;
# # my $x =  $if->{ x } + 10;
# # $if->{ cursor } =  Cursor->new( $if->{x}+10, $if->{y}, 4, $if->{h} );
# # $h->{ app }->refresh_over( $e->motion_x, $e->motion_y );
# # }

sub on_press{
 	my( $if, $h, $e ) =  @_;

 	if( defined( $if->{ cursor } ) ){ return; }

 	$if->{ cursor } = 1; 

	push $if->{ children }->@*, NewCursor->new( $if->{x}, $if->{y} - 1, 2, $if->{h} - 4);

	# DB::x;

	# $h->{ app }->refresh_over( $e->motion_x, $e->motion_y );
}


sub on_keydown {
	my( $if, $h, $e ) =  @_;

	$if->{ cursor }   or return;

	$map->{ SDL::Events::get_key_name( $e->key_sym ) }->( $if, $e );

	$if->{ message } =  &new_text( $if, $e );

	$if->SUPER::propagate( "on_keydown" );

}


sub store { }
# sub on_mouse_over { }
# sub on_mouse_out { }
# sub on_move { }
sub get_sb_coords { }

1;
