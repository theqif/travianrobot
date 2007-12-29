package Travian;

use strict;
use warnings;

require Exporter;

use Carp;
use LWP::UserAgent;
use HTTP::Request;

use Travian::Village;
use Travian::Resources;
use Travian::Construction qw(gid2name name2gid);

our @ISA = qw(LWP::UserAgent Exporter);
our @EXPORT_OK = qw(&calc_traveltime);

our $VERSION = '0.01';
our $AUTOLOAD;

my $DEFAULT_USER_AGENT = 'Mozilla/5.0 (X11; U; Linux x86_64; en-GB; rv:1.8.1.11) Gecko/20071204 Ubuntu/7.10 (gutsy) Firefox/2.0.0.11';

my $DEFAULT_TRAVIAN_SERVER = 3;
my $TRAVIAN_BASE_URL = '.travian.co.uk/';
my $TRAVIAN_CONSTRUCTION_URL = 'http://help.travian.co.uk/index.php?type=faq&gid=';

=head1 NAME

Travian - a package for the web-based game Travian.

=head1 SYNOPSIS

  use Travian;
  my $travian = Travian->new(4, agent => 'Mozilla/5.0');

  if (!$travian->login($user, $pass))
  {
    print $travian->error_msg();
  }
  $travian->logged_in();

  print $travian->server();
  print $travian->base_url();

  my $village = $travian->village($village_id);
  $village = $travian->next_village();
  $village = $travian->village_overview();
  $travian->no_of_villages();

  $travian->send_troops($type, $x, $y, Travian::Troops::Gauls->new(10), $scout_type);

  my $woodcutter = $travian->construction(1);

  $travian->logout();

=head1 DESCRIPTION

This package defines routines for the web-based game Travian.

=head1 CONSTANTS

=head2 ATTACK_REINFORCEMENT

Constant for send troops. Send reinforcements.

=head2 ATTACK_NORMAL

Constant for send troops. Send a normal attack.

=head2 ATTACK_RAID

Constant for send troops. Send a raid attack.

=head2 SCOUT_RESOURCES

Constant for send troops. Scout for resources and troops.

=head2 SCOUT_DEFENCES

Constant for send troops. Scout for defences and troops.

=cut

use constant ATTACK_REINFORCEMENT => 2;
use constant ATTACK_NORMAL => 3;
use constant ATTACK_RAID => 4;

use constant SCOUT_RESOURCES => 1;
use constant SCOUT_DEFENCES => 2;

=head1 METHODS

=head2 new()

  use Travian;

  my $travian = Travian->new($server_no, $ua_args);

Create a new instance of the Travian object.
If $server_no is not given a default of 3 is used.
The Travian package is sub-classed from LWP::UserAgent and so optional $ua_args
can be passed as second argument. See LWP::UserAgent for details.

=cut

sub new
{
	my $class = shift;
	my $server = shift;
	my $self = $class->SUPER::new(@_);
	
	return $self->_init($server);
}

sub _init
{
	my $self = shift;
	my $server = shift;

	$self->{'server'} = $server && $server > 0 && $server < 5 ? $server : $DEFAULT_TRAVIAN_SERVER;
	$self->{'error_msg'} = '';

	$self->agent($DEFAULT_USER_AGENT) if ($self->agent() =~ /libwww/);
	$self->cookie_jar({ }) if (!defined($self->cookie_jar()));

	$self->{'village'} = Travian::Village->new();
	$self->{'villages'} = [];
	$self->{'village_index'} = 0;

	$self->{'current_resources'} = Travian::Resources->new();
	$self->{'max_resources'} = Travian::Resources->new();
	$self->{'production_resources'} = Travian::Resources->new();

	return $self;
}

=head2 server()

  $travian->server();

Returns the current Travian server number.

=cut

sub server
{
	return $_[0]->{'server'};
}

=head2 base_url()

  $travian->base_url();

Returns the base url of the current Travian server.

=cut

sub base_url
{
	return 'http://s' . $_[0]->server() . $TRAVIAN_BASE_URL;
}

=head2 error_msg()

  $travian->error_msg();

Returns the error message if any.

=cut

sub error_msg
{
	return $_[0]->{'error_msg'};
}

=head2 login()

  $travian->login($user, $pass);

Log into Travian with given user and pass.
Returns 1 on success.
Use $travian->error_msg() to retrieve error message on failure.

=cut

sub login
{
	my $self = shift;
	my $user = shift;
	my $pass = shift;

	$self->{'error_msg'} = '';

	if ($self->logged_in())
	{
		return $self->village();
	}

	if ($user && $pass)
	{
		my $login_args = &parse_login_form($self->get_login_form(), $user, $pass);
		if ($login_args)
		{
			my $login_form_res_html = $self->post_login_form($login_args);
			if ($login_form_res_html)
			{
				$self->{'error_msg'} = &parse_login_error_msg($login_form_res_html);
				if (!$self->{'error_msg'})
				{
					return $self->parse_villages($login_form_res_html);
				}
			}
			else { $self->{'error_msg'} = 'Cannot post login form.'; }
		}
		else { $self->{'error_msg'} = 'Cannot retrieve login form.'; }
	}

	return;
}

=head2 logged_in()

  $travian->logged_in();
  returns BOOLEAN 

=cut

sub logged_in
{
        my $self = shift;

        my $ov_p= $self->get($self->base_url() . '/dorf1.php');

        if ($ov_p->is_success)
        {
                return 1 if ($ov_p->content() =~ m#logout.php#msg);
        }

        return 0;
}

=head2 get_login_form()

  $travian->get_login_form();

Retrieves the Travian login form.
Used by $travian->login().

=cut

sub get_login_form
{
	my $self = shift;
	
	my $login_form_res = $self->get($self->base_url() . '/login.php');

	if ($login_form_res->is_success)
	{
		$login_form_res->content() =~ m#<form.+?>(.+?)</form>#msg;
		my $login_form = $1;

		return $login_form;
	}

	return;
}

=head2 post_login_form()

  $travian->post_login_form($login_args);

Posts the Travian login form.
Used by $travian->login().

=cut

sub post_login_form
{
	my $self = shift;
	my $login_args = shift;

	if ($login_args)
	{
		my $login_form_res = $self->post($self->base_url() . '/dorf1.php', $login_args);

		if ($login_form_res->is_success)
		{
			return $login_form_res->content();
		} 
	}

	return;
}

=head2 logout()

  $travian->logout();

Log out of Travian.

=cut

sub logout
{
	my $self = shift;

	my $logout_res = $self->get($self->base_url() . '/logout.php');

	return $logout_res->is_success;
}

=head2 village()

  $travian->village();
  $travian->village($village_id);

Returns the Travian village.

=cut

sub village
{
	my $self = shift;

	$self->{'error_msg'} = '';

	if (@_)
	{
		my $village_id = shift;
		if ($village_id =~ /\d+/)
		{
			my $village_index = $self->village_id2index($village_id);
			if ($village_index < 0)
			{
				$self->{'error_msg'} = 'Invalid village id.';
				return;
			}

			$self->{'village_index'} = $village_index;
			
			return $self->village_overview($village_id);
		}
	}

	if ($self->no_of_villages() && $self->{'village_index'} < $self->no_of_villages())
	{
		return $self->{'villages'}->[$self->{'village_index'}];
	}

	$self->{'error_msg'} = 'No villages found.';

	return;
}

=head2 next_village()

  $travian->next_village();
  
Returns the next Travian village.

=cut

sub next_village
{
	my $self = shift;

	$self->{'error_msg'} = '';

	if ($self->no_of_villages())
	{
		$self->{'village_index'}++;
		$self->{'village_index'} = 0 unless $self->{'village_index'} < $self->no_of_villages();

		if ($self->village()->village_id())
		{
			return $self->village_overview($self->village()->village_id());
		}

		return $self->village();
	}

	$self->{'error_msg'} = 'No villages found.';

	return;
}

=head2 no_of_villages()

  $travian->no_of_villages();

Returns the number of villages.

=cut

sub no_of_villages
{
	return $#{$_[0]->{'villages'}} + 1;
}

=head2 village_id2index()

  $travian->village_id2index($village_id);

Given a village id returns the index in the village array.
Used by $travian->village().

=cut

sub village_id2index
{
	my $self = shift;
	my $id = shift;
	my $index = 0;

	foreach my $village (@{$self->{'villages'}})
	{
		if ($village->village_id() == $id)
		{
			return $index;
		}

		$index++;
	}

	return -1;
}

=head2 parse_villages()

  $travian->parse_villages($village_overview_html);

Parses the villages from the given village overview html and
returns the current village.
Used by $travian->login().

=cut

sub parse_villages
{
	my $self = shift;
	my $village_overview_html = shift;

	$self->{'error_msg'} = '';

	if ($village_overview_html && $village_overview_html =~ /logout.php/msg)
	{	
		my $villages = [ $village_overview_html =~ m#(<a href="\?newdid=.+?</tr>)#mgs ];
		$self->{'villages'} = [];

		if ($#{@{$villages}} > 0)		
		{
			# multiple villages
			my $village_index = 0;
			
			foreach my $village (@{$villages})
			{
				my ($village_id, $village_name, $x, $y);
				
				if ($village =~ m#newdid=(\d+?)"#msg) {	$village_id = $1; }
				if ($village =~ m#(class="active\_vl")#msg) { $self->{'village_index'} = $village_index; }
				if ($village =~ m#>(.+?)</a>#msg) { $village_name = $1;	}
				if ($village =~ m#right dlist1">\((\d+?)<#msg) { $x = $1; }
				if ($village =~ m#left dlist3">(\d+?)\)<#msg) {	$y = $1; }

				my $village_obj = Travian::Village->new($village_name, $village_id);
				$village_obj->x($x);
				$village_obj->y($y);
				
				push(@{$self->{'villages'}}, $village_obj);

				$village_index++;
			}
		}
		else
		{
			# single village
			push(@{$self->{'villages'}}, Travian::Village->new());
			$self->{'village_index'} = 0;
		}
		
		return $self->{'villages'}->[$self->{'village_index'}]->parse_village_overview($village_overview_html);
	}

	$self->{'error_msg'} = 'Cannot parse villages.';

	return;
}

=head2 village_overview()

  $travian->village_overview();

Retrieve the village overview and return the current village.

=cut

sub village_overview
{
	my $self = shift;
	my $village_overview_url = $self->base_url() . '/dorf1.php';

	$self->{'error_msg'} = '';

	if ($self->village())
	{
		if (@_)
		{
			my $village_id = shift;
			if ($village_id =~ /\d+/ && $village_id == $self->village()->village_id())
			{
				$village_overview_url .= '?newdid=' . $village_id; 
			}
			else
			{
				$self->{'error_msg'} = 'Invalid village id.';

				return;
			}
		}

		my $village_overview_res = $self->get($village_overview_url);

		if ($village_overview_res->is_success)
		{
			return $self->village()->parse_village_overview($village_overview_res->content);
		}

		$self->{'error_msg'} = 'Cannot retrieve village overview.';

		return;		
	}

	$self->{'error_msg'} = 'No village found.';

	return;
}

=head2 send_troops()

  $travian->send_troops($attack_type, $x, $y, $troops, $scout_type);

Send the given troops on an attack of type $attack_type to coordinates $x, $y.
The attack type is 2 for reinforcements, 3 for normal and 4 for raid.
The troops are of type Travian::Troops.
The scout type is 1 for resources and 2 for defences. Only used when a spy type
troop is sent. Defaults to resources.

=cut

sub send_troops
{
	my $self = shift;
	my ($type, $x, $y, $troops, $scout_type) = @_;

	$self->{'error_msg'} = '';

	$type = 2 unless $type > 1;
	$type = 4 unless $type < 5;

	$scout_type = 1 unless $scout_type && $scout_type == 2;

	if ($troops && ref($troops) =~ /Travian::Troops/)
	{
		my $send_troops_confirm_form = $self->post_send_troops_form($type, $x, $y, $troops);
		if ($send_troops_confirm_form)
		{
			my $send_troops_confirm_args = &parse_send_troops_confirm_form($send_troops_confirm_form, $scout_type);
			if ($send_troops_confirm_args)
			{
				return $self->post($self->base_url() . '/a2b.php', $send_troops_confirm_args);
			}

			$self->{'error_msg'} = &parse_send_troops_error_msg($send_troops_confirm_form);
			return;
		}

		$self->{'error_msg'} = 'Cannot post send troops form.';
		return;
	}

	$self->{'error_msg'} = 'Invalid troops.';

	return;
}

=head2 post_send_troops_form()

  $travian->post_send_troops_form($type, $x, $y, $troops);

Posts the Travian send troops form.
Used by $travian->send_troops().

=cut

sub post_send_troops_form
{
	my $self = shift;
	my ($type, $x, $y, $troops) = @_;

	my $send_troops_args = [b => 1, c => $type, dname => '', x => $x, y => $y, s1 => 'ok'];
	push @{$send_troops_args}, @{$troops->send_troops_args()};

	my $send_troops_res = $self->post($self->base_url() . '/a2b.php', $send_troops_args);

	if ($send_troops_res->is_success)
	{
		return $send_troops_res->content();
	}

	return;
}

=head2 construction()

  $travian->construction($gid);

Return the construction costs and times for the given gid.
Returns a Travian::Construction object.

=cut

sub construction
{
	my $self = shift;
	my $gid = shift;

	if ($gid && $gid > 0 && $gid < 41)
	{
		my $construction_res = $self->get($TRAVIAN_CONSTRUCTION_URL . $gid);

		if ($construction_res->is_success)
		{
			my $construction = Travian::Construction->new($gid);
			return $construction->parse_construction($construction_res->content);
		}
	}

	return;
}

=head1 PARSE FUNCTIONS

=head2 parse_login_form()

  &parse_login_form($login_form, $user, $pass);

Parse the login form html and return an array ref of the form input values.

=cut

sub parse_login_form
{
	my $login_form = shift;
	my $user = shift;
	my $pass = shift;

	if ($login_form && $user && $pass)
	{
		$login_form =~ m#hidden" name="login" value="(.+?)"#msg;
		my $login_id = $1;
		$login_form =~ m#"fm fm110" type="text" name="(.+?)"#msg;
		my $user_fn = $1;
		$login_form =~ m#"fm fm110" type="password" name="(.+?)"#msg;
		my $pass_fn  = $1;
		$login_form =~ m#<p align="center"><input type="hidden" name="(.+?)" value="(.*?)">#msg;
		my $rand_hid = $1;
		my $rand_val = $2;

		return [w => '400:800', login => $login_id, $user_fn => $user, $pass_fn => $pass, $rand_hid => $rand_val, s1 => 'login'];
	}

	return;
}

=head2 parse_login_error_msg()

  &parse_login_error_msg($login_html);

Parse and return the error message in the login html page.

=cut

sub parse_login_error_msg
{
	my $html = shift;

	$html =~ m#<span class="e f7">(.+?)</span>#mg;
	my $error_msg = $1;

	return $error_msg;
}

=head2 parse_send_troops_confirm_form()

  &parse_send_troops_confirm_form($send_troops_confirm_form, $scout_type);

Parse the send troops confirm form html and return an array ref of the form input values.

=cut

sub parse_send_troops_confirm_form
{
	my $send_troops_confirm_form = shift;
	my $scout_type = shift;

	if ($send_troops_confirm_form && $send_troops_confirm_form =~ m#\>Destination\:\<\/td\>#msg)
	{
		$send_troops_confirm_form =~ m#name="id" value="(.+?)"#msg;
		my $id = $1;
		$send_troops_confirm_form =~ m#name="a" value="(.+?)"#msg;
		my $a = $1;
		$send_troops_confirm_form =~ m#name="c" value="(.+?)"#msg;
		my $c = $1;
		$send_troops_confirm_form =~ m#name="kid" value="(.+?)"#msg;
		my $kid = $1;
		$send_troops_confirm_form =~ m#name="t1" value="(.+?)"#msg;
		my $t1 = $1;
		$send_troops_confirm_form =~ m#name="t2" value="(.+?)"#msg;
		my $t2 = $1;
		$send_troops_confirm_form =~ m#name="t3" value="(.+?)"#msg;
		my $t3 = $1;
		$send_troops_confirm_form =~ m#name="t4" value="(.+?)"#msg;
		my $t4 = $1;
		$send_troops_confirm_form =~ m#name="t5" value="(.+?)"#msg;
		my $t5 = $1;
		$send_troops_confirm_form =~ m#name="t6" value="(.+?)"#msg;
		my $t6 = $1;
		$send_troops_confirm_form =~ m#name="t7" value="(.+?)"#msg;
		my $t7 = $1;
		$send_troops_confirm_form =~ m#name="t8" value="(.+?)"#msg;
		my $t8 = $1;
		$send_troops_confirm_form =~ m#name="t9" value="(.+?)"#msg;
		my $t9 = $1;
		$send_troops_confirm_form =~ m#name="t10" value="(.+?)"#msg;
		my $t10 = $1;
		$send_troops_confirm_form =~ m#name="t11" value="(.+?)"#msg;
		my $t11 = $1;

		my $send_troops_confirm_args = 
		[
			id => $id, a => $a, c => $c, kid => $kid, s1 => 'ok',
			t1 => $t1, t2 => $t2, t3 => $t3, t4 => $t4, t5 => $t5,
			t6 => $t6, t7 => $t7, t8 => $t8, t9 => $t9, t10 => $t10, t11 => $t11,
		];

		if ($send_troops_confirm_form =~ /input type="Radio" name="spy"/)
		{
			push @{$send_troops_confirm_args}, spy => $scout_type;
		}

		return $send_troops_confirm_args;
	}

	return;
}

=head2 parse_send_troops_error_msg()

  &parse_send_troops_error_msg($send_troops_html);

Parse and return the error message in the send troops html page.

=cut

sub parse_send_troops_error_msg
{
	my $html = shift;

	$html =~ m#<div class="f10 e b">(.+?)</div>#mg;
	my $error_msg = $1;
	$error_msg =~ s#<span>##;
	$error_msg =~ s#</span>##;

	return $error_msg;
}

=head1 FUNCTIONS

=head2 calc_traveltime()

  &calc_traveltime($attacker_x, $attacker_y, $defender_x, $defender_y, $velocity);
  
Returns the travel time in seconds to go from coords $attacker_x, $attacker_y to coords
$defender_x, $defender_y at given velocity.

=cut

sub calc_traveltime
{
	my ($x1, $y1, $x2, $y2, $v) = @_;

	my $dx = $x1 - $x2;
	$dx = $dx * -1 unless $dx > 0;
	my $dy = $y1 - $y2;
	$dy = $dy * -1 unless $dy > 0;

	my $d = sqrt($dx*$dx + $dy*$dy);
	
	return ($d/$v)*3600;
}

=head1 AUTHOR

Adrian D. Elgar, E<lt>ade@wasters.comE<gt>
Martin Robertson, E<lt>marley@wasters.comE<gt>

=head1 SEE ALSO

LWP::UserAgent, Travian::Village, Travian::Resources, Travian::Construction

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Adrian Elgar, Martin Robertson

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut

1;
