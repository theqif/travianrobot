#!/usr/bin/perl -w

use lib '../lib/';
use Travian qw(calc_traveltime);
use Travian::Troops::Gauls;
use Carp;

my $SERVER = 3;
my $USERAGENT = 'Mozilla/5.0 (X11; U; Linux x86_64; en-GB; rv:1.8.1.11) Gecko/20071204 Ubuntu/7.10 (gutsy) Firefox/2.0.0.11';
my $X = 92;
my $Y = -5;
my $TT = 30;

my $user = shift;
my $pass = shift;
my $wave = shift;
my $village_id = shift;

die "usage: $0 [user] [pass] [wave] [village_id]\n" unless $user && $pass && $wave;

my $travian = Travian->new($SERVER, agent => $USERAGENT);

my $gauls = Travian::Troops::Gauls->new();
$gauls->theutates_thunder($TT);

while (1)
{
	if (!$wave || $wave == 1)
	{
		if (!$travian->login($user, $pass))
		{
			croak $travian->error_msg();
		}

		if ($village_id && !$travian->village($village_id))
		{
			croak $travian->error_msg();
		}

		## Wave (x) - (93|-5) Hathor Village (03:09 mins)
		my $hathor = Travian::Troops::Gauls->new();
		$hathor->theutates_thunder(9);
		if (!$travian->send_troops(Travian::ATTACK_RAID, 93, -5, $hathor))
		{
			croak $travian->error_msg();
		}
		print &log_msg('x', 93, -5, 'Hathor Village');
		print "\n";

		## Wave (1) - (87|-2) Caen (18:24 mins)
		if (!$travian->send_troops(Travian::ATTACK_RAID, 87, -2, $gauls))
		{
			croak $travian->error_msg();
		}
		print &log_msg(1, 87, -2, 'Caen');
		print "\n";
		## Wave (1) - (96|-10) gryphongod Village (20:13 mins)
		if (!$travian->send_troops(Travian::ATTACK_RAID, 96, -10, $gauls))
		{
			croak $travian->error_msg();
		}
		print &log_msg(1, 96, -10, 'gryphongod Village');
		print "\n";		
		sleep int(&calc_traveltime($X, $Y, 96, -10, 19)) * 2 + 10;

		$wave = 0;
	}

	if (!$wave || $wave == 2)
	{
		if (!$travian->login($user, $pass))
		{
			croak $travian->error_msg();
		}

		if ($village_id && !$travian->village($village_id))
		{
			croak $travian->error_msg();
		}
		
		## Wave (x) - (93|-5) Hathor Village (03:09 mins)
		my $hathor = Travian::Troops::Gauls->new();
		$hathor->theutates_thunder(9);
		if (!$travian->send_troops(Travian::ATTACK_RAID, 93, -5, $hathor))
		{
			croak $travian->error_msg();
		}
		print &log_msg('x', 93, -5, 'Hathor Village');
		print "\n";

		## Wave (2) - (99|-4) thanh3 Village (22:19 mins)
		if (!$travian->send_troops(Travian::ATTACK_RAID, 99, -4, $gauls))
		{
			croak $travian->error_msg();
		}
		print &log_msg(2, 99, -4, 'thanh3 Village');
		print "\n";
		## Wave (2) - (96|1) Barnfield (22:46 mins)
		if (!$travian->send_troops(Travian::ATTACK_RAID, 96, 1, $gauls))
		{
			croak $travian->error_msg();
		}
		print &log_msg(2, 96, 1, 'Barnfield');
		print "\n";		
		sleep int(&calc_traveltime($X, $Y, 96, 1, 19)) * 2 + 10;
		
		$wave = 0;
	}

	if (!$wave || $wave == 3)
	{
		if (!$travian->login($user, $pass))
		{
			croak $travian->error_msg();
		}

		if ($village_id && !$travian->village($village_id))
		{
			croak $travian->error_msg();
		}

		## Wave (x) - (93|-5) Hathor Village (03:09 mins)
		my $hathor = Travian::Troops::Gauls->new();
		$hathor->theutates_thunder(9);
		if (!$travian->send_troops(Travian::ATTACK_RAID, 93, -5, $hathor))
		{
			croak $travian->error_msg();
		}
		print &log_msg('x', 93, -5, 'Hathor Village');
		print "\n";

		## Wave (2) - (96|-13) pspeter1 Village (28:14 mins)
		if (!$travian->send_troops(Travian::ATTACK_RAID, 96, -13, $gauls))
		{
			croak $travian->error_msg();
		}
		print &log_msg(3, 96, -13, 'pspeter1 Village');
		print "\n";
		## Wave (2) - (95|4) HumpdeBump Village (29:57 mins)
		if (!$travian->send_troops(Travian::ATTACK_RAID, 95, 4, $gauls))
		{
			croak $travian->error_msg();
		}
		print &log_msg(3, 95, 4, 'HumpdeBump Village');
		print "\n";
		sleep int(&calc_traveltime($X, $Y, 95, 4, 19)) * 2 + 10;
		
		$wave = 0;
	}

	
	if (!$wave || $wave == 4)
	{
		if (!$travian->login($user, $pass))
		{
			croak $travian->error_msg();
		}

		if ($village_id && !$travian->village($village_id))
		{
			croak $travian->error_msg();
		}

		## Wave (x) - (93|-5) Hathor Village (03:09 mins)
		my $hathor = Travian::Troops::Gauls->new();
		$hathor->theutates_thunder(9);
		if (!$travian->send_troops(Travian::ATTACK_RAID, 93, -5, $hathor))
		{
			croak $travian->error_msg();
		}
		print &log_msg('x', 93, -5, 'Hathor Village');
		print "\n";

		## Wave (4) - (102|-6) Tatooine (31:44 mins)
		if (!$travian->send_troops(Travian::ATTACK_RAID, 102, -6, $gauls))
		{
			croak $travian->error_msg();
		}
		print &log_msg(4, 102, -6, 'Tatooine');
		print "\n";
		## Wave (4) - (103|-6) Guinevere Village (34:52 mins)
		if (!$travian->send_troops(Travian::ATTACK_RAID, 103, -6, $gauls))
		{
			croak $travian->error_msg();
		}
		print &log_msg(4, 103, -6, 'Guinevere Village');
		print "\n";
		sleep int(&calc_traveltime($X, $Y, 103, -6, 19)) * 2 + 10;

		$wave = 0;
	}

	if (!$wave || $wave == 5)
	{
		if (!$travian->login($user, $pass))
		{
			croak $travian->error_msg();
		}

		if ($village_id && !$travian->village($village_id))
		{
			croak $travian->error_msg();
		}

		## Wave (x) - (93|-5) Hathor Village (03:09 mins)
		my $hathor = Travian::Troops::Gauls->new();
		$hathor->theutates_thunder(9);
		if (!$travian->send_troops(Travian::ATTACK_RAID, 93, -5, $hathor))
		{
			croak $travian->error_msg();
		}

		## Wave (5) - (97|-11) toridog Village (24:39 mins)
		if (!$travian->send_troops(Travian::ATTACK_RAID, 97, -11, $gauls))
		{
			croak $travian->error_msg();
		}
		print &log_msg(5, 97, -11, 'toridog Village');
		print "\n";
		sleep int(&calc_traveltime($X, $Y, 97, -11, 19)) * 2 + 10;

		$wave = 0;
	}
}

sub log_msg
{
	my ($wave, $x, $y, $village) = @_;

	return '[' . scalar(localtime()) . "] Wave ($wave) - ($x|$y) $village (" . &traveltime($x, $y) . ' mins)';
}

sub traveltime
{
	my ($x, $y) = @_;

	my $seconds = &calc_traveltime($X, $Y, $x, $y, 19);

	# there and back again.
	return int($seconds*2 / 60) . ':' . int((($seconds*2 / 60) - int($seconds*2 / 60)) * 60);
}

#
# Old Targets
#

		## Wave (1) - (95|-1) Chewitonia (15:47 mins)
		#if (!$travian->send_troops(Travian::ATTACK_RAID, 95, -1, $gauls))
		#{
		#	croak $travian->error_msg();
		#}
		#print &log_msg(1, 95, -1, 'Chewitonia');
		#print "\n";

		## Wave (3) - (94|-15) dan4sam Village (32:12 mins)
		#if (!$travian->send_troops(Travian::ATTACK_RAID, 94, -15, $gauls))
		#{
		#	croak $travian->error_msg();
		#}
		#print &log_msg(3, 94, -15, 'dan4sam Village');
		#print "\n";

		## Wave (3) - (105|-7) Gieger Village (41:32 mins)
		#if (!$travian->send_troops(Travian::ATTACK_RAID, 105, -7, $gauls))
		#{
		#	croak $travian->error_msg();
		#}
		#print &log_msg(3, 105, -7, 'Gieger Village');
		#print "\n";
		#sleep int(&calc_traveltime($X, $Y, 105, -7, 19)) * 2 + 10;

