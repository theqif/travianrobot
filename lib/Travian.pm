package Travian;

use 5.008008;
use strict;
use warnings;

use Carp;
use LWP::UserAgent;
use HTTP::Request;

use Travian::Village;
use Travian::Resources;
use Travian::Construction qw(gid2name name2gid);

our @ISA = qw(LWP::UserAgent);

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
  my $travian = Travian->new(4, {agent => 'Mozilla/5.0'});

  if (!$travian->login($user, $pass))
  {
    print $travian->error_msg();
  }

  print $travian->server();
  print $travian->base_url();

  my $village = $travian->village();
  $village = $travian->village_overview();

  $travian->send_troops($type, $x, $y, Travian::Troops->new(10));

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
use constant SCOUT_DEFENCES = 2;

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

=head2 village()

  $travian->village();

Returns the Travian village.

=cut

sub village
{
	return $_[0]->{'village'};
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

	if ($user && $pass)
	{
		my $login_args = &parse_login_form($self->get_login_form(), $user, $pass);
		if ($login_args)
		{
			my $login_form_res_html = $self->post_login_form($login_args);
			if ($login_form_res_html)
			{
				$self->{'error_msg'} = &parse_error_msg($login_form_res_html);
				if (!$self->{'error_msg'})
				{
					return $self->village()->parse_village_overview($login_form_res_html);
				}
			}
			else { $self->{'error_msg'} = 'Cannot post login form.'; }
		}
		else { $self->{'error_msg'} = 'Cannot retrieve login form.'; }
	}

	return;
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

=head2 village_overview()

  $travian->village_overview();

Retrieve the village overview and return the current village.

=cut

sub village_overview
{
	my $self = shift;

	my $village_overview_res = $self->get($self->base_url() . '/dorf1.php');

	if ($village_overview_res->is_success)
	{
		return $self->village()->parse_village_overview($village_overview_res->content);
	}

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

	$type = 2 unless $type > 1;
	$type = 4 unless $type < 5;

	$scout_type = 1 unless $scout_type == 2;

	if ($troops && ref($troops) =~ /Travian::Troops/)
	{
		my $send_troops_confirm_args = &parse_send_troops_confirm_form($self->post_send_troops_form($type, $x, $y, $troops), $scout_type);
		if ($send_troops_confirm_args)
		{
			return $self->post($self->base_url() . '/a2b.php', $send_troops_confirm_args);
		}
	}

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
		$send_troops_res->content() =~ m#<form.+?>(.+?)</form>#msg;
		my $send_troops_confirm = $1;

		return $send_troops_confirm;
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
		$login_form =~ m#<p align="center"><input type="hidden" name="(.+?)" value="">#msg;
		my $rand_hid = $1;

		return [w => '400:800', login => $login_id, $user_fn => $user, $pass_fn => $pass, $rand_hid => '', s1 => 'login'];
	}

	return;
}

=head2 parse_error_msg()

  &parse_error_msg($page_html);

Parse and return the error message in a given html page.

=cut

sub parse_error_msg
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

	if ($send_troops_confirm_form)
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
