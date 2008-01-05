package Travian;

use strict;
use warnings;

require Exporter;

use Carp;
use LWP::UserAgent;
use HTTP::Request;

use Travian::Village;
use Travian::Resources;
use Travian::Building qw(gid2name name2gid);
use Travian::Report;

our @ISA = qw(LWP::UserAgent Exporter);
our @EXPORT_OK = qw(&calc_traveltime);

our $VERSION = '0.01';
our $AUTOLOAD;

my $DEFAULT_USER_AGENT = 'Mozilla/5.0 (X11; U; Linux x86_64; en-GB; rv:1.8.1.11) Gecko/20071204 Ubuntu/7.10 (gutsy) Firefox/2.0.0.11';

my $DEFAULT_TRAVIAN_SERVER = 3;
my $TRAVIAN_BASE_URL = '.travian.co.uk/';
my $TRAVIAN_CONSTRUCTION_URL = 'http://help.travian.co.uk/index.php?type=faq&gid=';

my $re =
{
  logout       => "(logout.php)",
  login        => "\?login",
  newdid       => "(<a href=\"\\?newdid=.+?<\/tr>)",
  villageid    => "newdid=(\\d+?)\"",
  villageindex => qq~(class="active\_vl")~,
  villagename  => ">(.+?)</a>",
  villagex     => "right dlist1\">\\((\\d+?)<",
  villagey     => "left dlist3\">(\\d+?)\\)<",
  login_login  => "hidden\" name=\"login\" value=\"(.+?)\"",
  login_text   => "\"fm fm110\" type=\"text\" name=\"(.+?)\"",
  login_pass   => "\"fm fm110\" type=\"password\" name=\"(.+?)\"",
  login_rand   => "<p align=\"center\"><input type=\"hidden\" name=\"(.+?)\" value=\"(.*?)\">",
  login_rand_key   => "<p align=\"center\"><input type=\"hidden\" name=\"(.+?)\"",
  login_rand_val   => "<p align=\"center\"><input type=\"hidden\" name=\".+?\" value=\"(.*?)\">",
  login_form   => "<form.+?>(.+?)</form>",
  login_error  => "<span class=\"e f7\">(.+?)</span>",
  st_error     => "<div class=\"f10 e b\">(.+?)</div>",
  st_dest      => ">Destination:</td>",
  st_id        => "name=\"id\" value=\"(.+?)\"",
  st_a         => "name=\"a\" value=\"(.+?)\"",
  st_c         => "name=\"c\" value=\"(.+?)\"",
  st_kid       => "name=\"kid\" value=\"(.+?)\"",
  st_t1        => "name=\"t1\" value=\"(.+?)\"",
  st_t2        => "name=\"t2\" value=\"(.+?)\"",
  st_t3        => "name=\"t3\" value=\"(.+?)\"",
  st_t4        => "name=\"t4\" value=\"(.+?)\"",
  st_t5        => "name=\"t5\" value=\"(.+?)\"",
  st_t6        => "name=\"t6\" value=\"(.+?)\"",
  st_t7        => "name=\"t7\" value=\"(.+?)\"",
  st_t8        => "name=\"t8\" value=\"(.+?)\"",
  st_t9        => "name=\"t9\" value=\"(.+?)\"",
  st_t10       => "name=\"t10\" value=\"(.+?)\"",
  st_t11       => "name=\"t11\" value=\"(.+?)\"",
};

my $meta =
{
  logged_in =>{ get=>{url=>'/dorf1.php',re=>[{logged_in=>$re->{logout}}],},},

  login =>
  {
    get =>
    {
      url => '/login.php',
      re  =>
      [
        {login    => $re->{login_login}},
        {user_fn  => $re->{login_text}},
        {pass_fn  => $re->{login_pass}},
        {rand_hid => $re->{login_rand_key}},
        #{rand_val => $re->{login_rand_val}},
      ],
    },
    set =>
    {
      url         => '/dorf1.php',
      error_check => $re->{login_error},
    },
  },
};




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
  $village = $travian->village_centre();
  $travian->no_of_villages();

  $travian->send_troops($type, $x, $y, Travian::Troops::Gauls->new(10), $scout_type);

  my $woodcutter = $travian->construction(1);

  foreach my $report_header (@{$travian->report_headers(Travian::REPORT_ATTACKS)})
  {
     my $report = $travian->report($report_header->id());
  }

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

=head2 REPORT_REINFORCEMENT

Constant for report headers. Get reinforcement report headers.

=head2 REPORT_TRADE

Constant for report headers. Get trade report headers.

=head2 REPORT_ATTACKS

Constant for report headers. Get attack report headers.

=head2 REPORT_MISC

Constant for report headers. Get misc report headers.

=head2 REPORT_ARCHIVE

Constant for report headers. Get archive report headers.

=cut

use constant REPORT_REINFORCEMENT => 1;
use constant REPORT_TRADE => 2;
use constant REPORT_ATTACKS => 3;
use constant REPORT_MISC => 4;
use constant REPORT_ARCHIVE => 5;

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
	push @{$self->requests_redirectable}, 'POST';

	$self->{'village'} = Travian::Village->new();
	$self->{'villages'} = [];
	$self->{'village_index'} = 0;

	$self->{'current_resources'} = Travian::Resources->new();
	$self->{'max_resources'} = Travian::Resources->new();
	$self->{'production_resources'} = Travian::Resources->new();

	#$self->{'widgets'} = Travian::Widgets->new();

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

sub Dump { use Data::Dumper; print Dumper (\@_); }

=head2 login()

  $travian->login($user, $pass);

Log into Travian with given user and pass.
Returns 1 on success.
Use $travian->error_msg() to retrieve error message on failure.

=cut
sub mdr_login
{
	my $self = shift;
	my $e_args = shift;

	$self->{'error_msg'} = '';

	return $self->village() if ($self->logged_in());

	my $w_name = "login";

	# if 'widget->set/get' external-required-params have been passed & are valid
	#  clever munging / formatting of @_ ?
	$self->params_are_valid_get_ext($w_name, $e_args->{get});
        return if ($self->{'error_msg'});
	$self->params_are_valid_set_ext($w_name, $e_args->{set});
        return if ($self->{'error_msg'});

	# call widget-get
	#  which bring back meta-info-defined parsed vars & vals

	my $i_args = $self->widget_get($w_name, $e_args->{get});
	return if ($self->{'error_msg'});

my $ar = [w => '400:800', login => $i_args->{login}, $i_args->{user_fn} => $e_args->{get}->{user}, $i_args->{pass_fn} => $e_args->{get}->{pass}, $i_args->{rand_hid} => $i_args->{rand_val}, s1 => 'login'];
#print Dump ($i_args); print Dump ($ar);

	# if 'widget->set' internal-required-params have been retrieved & are valid
	$self->params_are_valid_set_int($w_name, $ar);
	return if ($self->{'error_msg'});

	my $res = $self->widget_set($w_name, $ar);
	return if ($self->{'error_msg'});

        return $self->parse_villages($res->content());
}

sub widget_set
{
  my $s  = shift;
  my $wn = shift;
  my $ar = shift;

  my $w = $meta->{$wn}->{set};

  my $res = $s->post($s->base_url . $w->{url}, $ar);

  print "Failed to POST" && return $res unless ($res->is_success);

  if (defined ($w->{error_check}))
  {
    if ($res->content() =~ m#$w->{error_check}#mgs)
    {
      $s->{'error_msg'} = $1; return;
    }
  }

  return $res;
}


sub widget_get
{
  my $s  = shift;
  my $wn = shift;
  my $hr = shift;


  my $w = $meta->{$wn}->{get};

  my $html = $s->get($s->base_url . $w->{url})->content();

#handle http error here

# hr->{get}->{user} hr->{get}->{pass} are already validated

my $ret = {};
  foreach my $re_hr (@{$w->{re}})
  {
    my $key = [keys %{$re_hr}]->[0];
    my $reg = $re_hr->{$key};
    if ($html =~ m#$reg#msg)
    {
      $ret->{$key} = $1;
    }
    else
    {
      $s->{error_msg} = "Cant match [$reg] in [$html]";
      return;
    }

  }

  return $ret;
}

sub params_are_valid_get_ext { return 1; }
sub params_are_valid_set_ext { return 1; }
sub params_are_valid_set_int { return 1; }

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

	my $res = $self->widget_get('logged_in');
	$self->{'error_msg'} = "";
	# ignore anything set here .. 

	return 1 if ($res->{'logged_in'});
 	return 0;

#        my $ov_p= $self->get($self->base_url() . '/dorf1.php');
#        if ($ov_p->is_success)
#        {
#                return 1 if ($ov_p->content() =~ m#$re->{logout}#msg);
#        }
#        return 0;
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
		$login_form_res->content() =~ m#$re->{login_form}#msg;
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
			
			return unless $self->village_overview();
			return $self->village_centre();
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
			if ($self->village_overview())
			{
				return $self->village_centre();
			}
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

Parses the list of villages from the given village overview html and
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
		my $villages = [ $village_overview_html =~ m#$re->{newdid}#mgs ];
		$self->{'villages'} = [];

		if ($#{@{$villages}} > 0)		
		{
			# multiple villages
			my $village_index = 0;
			
			foreach my $village (@{$villages})
			{
				my ($village_id, $village_name, $x, $y);

				if ($village =~ m#$re->{villageid}#msg) {	$village_id = $1; }
				if ($village =~ m#$re->{villageindex}#msg) { $self->{'village_index'} = $village_index; }
				if ($village =~ m#$re->{villagename}#msg) { $village_name = $1;	}
				if ($village =~ m#$re->{villagex}#msg) { $x = $1; }
				if ($village =~ m#$re->{villagey}#msg) {	$y = $1; }

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
		
		if ($self->village()->parse_village_overview($village_overview_html))
		{
			return $self->village_centre();
		}
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
		if (my $village_id = $self->village()->village_id())
		{
			$village_overview_url .= '?newdid=' . $village_id;
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

=head2 village_centre()

  $travian->village_centre();

Retrieve the village centre and return the current village.

=cut

sub village_centre
{
	my $self = shift;
	my $village_centre_url = $self->base_url() . '/dorf2.php';

	$self->{'error_msg'} = '';

	if ($self->village())
	{
		if (my $village_id = $self->village()->village_id())
		{
			$village_centre_url .= '?newdid=' . $village_id;
		}

		my $village_centre_res = $self->get($village_centre_url);

		if ($village_centre_res->is_success)
		{
			return $self->village()->parse_village_centre($village_centre_res->content);
		}

		$self->{'error_msg'} = 'Cannot retrieve village centre.';

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
				my $send_troops_confirm_res = $self->post($self->base_url() . '/a2b.php', $send_troops_confirm_args);
				if ($send_troops_confirm_res->is_success)
				{
					return $send_troops_confirm_res->content();
				}

				$self->{'error_msg'} = 'Cannot post send troops confirm form.';
				return;
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

Posts the Travian send troops form.2 420  	6 050  	3 025  	3 630
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
Returns a Travian::Building object.

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
			my $construction = Travian::Building->new($gid);
			return $construction->parse_construction($construction_res->content);
		}
	}

	return;
}

=head2 report()

  $travian->report($report_id);

Return the report for the given report id.
Returns a Travian::Report object.

=cut

sub report
{
	my $self = shift;
	my $report_id = shift;

	if ($report_id && $report_id =~ /\d+/)
	{
		my $report_res = $self->get($self->base_url() . '/berichte.php?id=' . $report_id);

		if ($report_res->is_success)
		{
			my $report = Travian::Report->new();
			return $report->parse_report($report_res->content);
		}
	}

	return;
}

=head2 report_headers()

  $travian->report_headers($report_section);

Returns an array ref of report headers for the given section.
Returns an array ref of Travian::Report::Header objects.

=cut

sub report_headers
{
	my $self = shift;
	my $report_section = shift;

	my $report_headers_url = $self->base_url() . '/berichte.php';
	if ($report_section && $report_section =~ /\d+/ && $report_section > 0 && $report_section < 6)
	{
		$report_headers_url .= '?t=' . $report_section;
	}

	my $report_headers = [];
	my $report_headers_res = $self->get($report_headers_url);

	if ($report_headers_res->is_success && $report_headers_res->content() =~ m#<h1>Reports</h1>#)
	{
		my $report_header_trs = [ $report_headers_res->content() =~ m#<tr>(.+?berichte.+?)</tr>#msg ];

		foreach my $header_tr (@{$report_header_trs})
		{
			if ($header_tr =~ m#berichte\.php\?id\=(\d+?)">(.+?)</a>.+?nowrap>(.+?)</td>#msg)
			{
				my $id = $1;
				my $subject = $2;
				my $sent = $3;

				my $header = Travian::Report::Header->new($subject, $sent);
				$header->id($id);

				push(@{$report_headers}, $header);
			}
		}
	}

	return $report_headers;
}

=head2 delete_reports()

  $travian->delete_reports(@report_ids);

Delete reports with the given ids.

=cut

sub delete_reports
{
  my $s   = shift;
  my $ar  = shift || [];

  my $params = {del=>'Delete'};

  my $i = 1;

  foreach my $rid (@{$ar})
  {
    $params->{'n'.$i++} = $rid;
    last if ($i > 10);
  }

  my $res = $s->post($s->base_url . "/berichte.php", $params);

  return $res->is_success;
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
		$login_form =~ m#$re->{login_login}#msg;
		my $login_id = $1;
		$login_form =~ m#$re->{login_text}#msg;
		my $user_fn = $1;
		$login_form =~ m#$re->{login_pass}#msg;
		my $pass_fn  = $1;
		$login_form =~ m#$re->{login_rand}#msg;
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

	$html =~ m#$re->{login_error}#mg;
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

	if ($send_troops_confirm_form && $send_troops_confirm_form =~ m#$re->{st_dest}#msg)
	{


		$send_troops_confirm_form =~  m#$re->{st_id}#msg; my $id  = $1;
		$send_troops_confirm_form =~   m#$re->{st_a}#msg; my $a   = $1;
		$send_troops_confirm_form =~   m#$re->{st_c}#msg; my $c   = $1;
		$send_troops_confirm_form =~ m#$re->{st_kid}#msg; my $kid = $1;
		$send_troops_confirm_form =~  m#$re->{st_t1}#msg; my $t1  = $1;
		$send_troops_confirm_form =~  m#$re->{st_t2}#msg; my $t2  = $1;
		$send_troops_confirm_form =~  m#$re->{st_t3}#msg; my $t3  = $1;
		$send_troops_confirm_form =~  m#$re->{st_t4}#msg; my $t4  = $1;
		$send_troops_confirm_form =~  m#$re->{st_t5}#msg; my $t5  = $1;
		$send_troops_confirm_form =~  m#$re->{st_t6}#msg; my $t6  = $1;
		$send_troops_confirm_form =~  m#$re->{st_t7}#msg; my $t7  = $1;
		$send_troops_confirm_form =~  m#$re->{st_t8}#msg; my $t8  = $1;
		$send_troops_confirm_form =~  m#$re->{st_t9}#msg; my $t9  = $1;
		$send_troops_confirm_form =~ m#$re->{st_t10}#msg; my $t10 = $1;
		$send_troops_confirm_form =~ m#$re->{st_t11}#msg; my $t11 = $1;

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

	$html =~ m#$re->{st_error}#mg;
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

sub get_vill
{
  return &parse_village_html(&get_village_page(shift()));
}
sub get_village_page
{
  return shift()->get("http://s3.travian.co.uk/karte.php?d=".shift())->content();
}
sub parse_village_html
{
  my $page = shift;
  my $vill = ();

  if ($page =~ m#Village \((-*\d+?)\|(-*\d+?)\)</div>#mg)  { $vill->{x} = $1; $vill->{y} = $2; }
#  if ($page =~ m#<h1>(.+?) Village #mg)   { $vill->{name} = $1; }
#  if ($page =~ m#<td> <b>(.+?)</b></td>#msg) { $vill->{tribe} = $1; }
#  if ($page =~ m#Population:</td><td><b> (\d+?)</b></td>#msg) { $vill->{population} = $1; }
#  if ($page =~ m#<a href="a2b.php\?z=(\d+?)">#msg) { $vill->{atak} = $1; }

#  my $rid_ar = [ $page =~ m#berichte.php\?id=(\d+?)"#msg ];
#  if ($page  =~ m#berichte.php\?id=#msg) { $vill->{reports} = join "|", @{$rid_ar}; }

  return () unless ($vill->{x});

  $vill->{ttime} = &calc_traveltime($vill->{x}, $vill->{y}, 19, 40, 19);

  return $vill;
}

sub parse_user
{
  my $page   = shift;
  my $player = ();

  if ($page  =~ m#<td class="rbg" colspan="3">Player (.+?)</td>#msg)       { $player->{name}       = $1; }
  if ($page  =~ m#<td class="s7">Rank:</td><td class="s7">(\d+?)</td>#msg) { $player->{rank}       = $1; }
  if ($page  =~ m#<td>Tribe:</td><td>(.+?)</td>#msg)                       { $player->{tribe}      = $1; }
  if ($page  =~ m#allianz.php\?aid=(\d+?)">#msg)                           { $player->{aid}        = $1; }
  if ($page  =~ m#<td>Villages:</td><td>(\d+?)</td>#msg)                   { $player->{villages}   = $1; }
  if ($page  =~ m#<td>Population:</td><td>(\d+?)</td>#msg)                 { $player->{population} = $1; }

  my $kid_ar = [ $page =~ m#karte.php\?d=(\d+&c=..)">#msg ];
  if ($page  =~ m#karte.php\?d=#msg) { $player->{vill_kid} = join "|", @{$kid_ar}; }

  return $player;
}

sub parse_alliance
{
  my $page = shift;
  my $all = ();

  if ($page =~ m#<td>Name:</td><td>(.+?)</td>#msg)                      { $all->{name}     = $1; }
  if ($page =~ m#<td>Points:</td><td>(\d+?)</td>#msg)                   { $all->{points}   = $1; }
  if ($page =~ m#<td>Members:</td><td>(\d+?)</td>#msg)                  { $all->{nmembers} = $1; }
  if ($page =~ m#<td>Rank:</td><td width="25%">(\d+?)\.</td>#msg)       { $all->{rank}     = $1; }
  if ($page =~ m#<td class="s7">Tag:</td><td class="s7">(.+?)</td>#msg) { $all->{tag}      = $1; }

  my $allies_id_ar = [ $page =~ m#allianz\.php\?aid=(\d+?)"#mgs ];
  if ($page  =~ m#allianz\.php\?aid=#msg) { $all->{allies} = join "|", @{$allies_id_ar}; }

  my $member_id_ar = [ $page =~ m#spieler\.php\?uid=(\d+?)"#msg ];
  if ($page  =~ m#spieler\.php\?uid=#msg) { $all->{members} = join "|", @{$member_id_ar}; }

  return $all;
}

sub get_report_ids
{
  my $s   = shift;
  my $res = $s->get($s->base_url . "/berichte.php");

  return [] unless ($res->is_success);

  return [ $res->content() =~ m#berichte.php\?id=(\d+?)"#msg ];
}

sub get_latest_map
{
  my $s = shift;
  my $url = $s->base_url . "map.sql";
  my $res = $s->get($url);

  croak "Error downloading [$url]\n" unless ($res->is_success);

  return $res->content();
}


sub parse_map_data
{
  my $s  = shift; my $map = shift;
  my $ix = shift; my $iy  = shift;

  my $ar = [];

  foreach my $row (split /\n/, $map)
  {
    $row =~ s/INSERT INTO `x_world` VALUES \(//; $row =~ s/\);//;

    my ($id, $x, $y, $vid, $pid, $pop) = ( split /,/, $row )[0,1,2,4,6,10];

    push @{$ar}, { id=>$id, pid=>$pid, vid=>$vid, x=>$x, y=>$y, pop=>$pop, tt => &calc_traveltime($x,$y,$ix,$iy,19), };
  }
  return $ar;
}

#id     Number of the field, starts in the top left corner at the coordinate (-400|400) and ends in the bottom right corner at (400|-400)
#x      X-Coordinate
#y      y-Coordinate
#tid    The tribe number. 1 = Roman, 2 = Teuton, 3 = Gaul, 4 = Nature and 5 = Natars
#vid    Village number
#village        Village name
#uid    Player number also known as User-ID
#player         Player name
#aid    Alliance number
#alliance       Alliance name
#population     The village's number of inhabitants



=head1 AUTHOR

Adrian D. Elgar, E<lt>ade@wasters.comE<gt>
Martin Robertson, E<lt>marley@wasters.comE<gt>

=head1 SEE ALSO

LWP::UserAgent, Travian::Village, Travian::Resources, Travian::Construction, Travian::Report

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Adrian Elgar, Martin Robertson

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut

1;
