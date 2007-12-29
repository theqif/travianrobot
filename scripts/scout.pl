#!/usr/bin/perl -w

use lib '../lib/';
use Travian;
use Travian::Troops::Gauls;
use Carp;

my $server = shift;
my $user = shift;
my $pass = shift;
my $x = shift;
my $y = shift;
my $village_id = shift;

die "usage: $0 [server] [user] [pass] [x] [y] [village_id]\n" unless $server && $user && $pass && $x && $y;

#my $USERAGENT = 'Mozilla/5.0 (X11; U; Linux x86_64; en-GB; rv:1.8.1.11) Gecko/20071204 Ubuntu/7.10 (gutsy) Firefox/2.0.0.11';
my $USERAGENT = "Mozilla/5.0 (Macintosh; U; Intel Mac OS X; en-US; rv:1.8.1.11) Gecko/20071127 Firefox/2.0.0.11";


my $travian = Travian->new($server, agent => $USERAGENT);
if (!$travian->login($user, $pass))
{
	croak $travian->error_msg();
}

if ($village_id && !$travian->village($village_id))
{
	croak $travian->error_msg();
}

my $gauls = Travian::Troops::Gauls->new();
$gauls->pathfinder(1);

if (!$travian->send_troops(Travian::ATTACK_RAID, $x, $y, $gauls, Travian::SCOUT_RESOURCES))
{
	croak $travian->error_msg();
}

#$travian->logout();


