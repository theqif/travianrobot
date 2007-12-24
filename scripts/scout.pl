#!/usr/bin/perl -w

use lib '../lib/';
use Travian;
use Travian::Troops::Gauls;

my $user = shift;
my $pass = shift;
my $x = shift;
my $y = shift;

die "usage: $0 [user] [pass] [x] [y]\n" unless $user && $pass && $x && $y;

my $travian = Travian->new();
if (!$travian->login($user, $pass))
{
	croak $travian->error_msg();
}

my $gauls = Travian::Troops::Gauls->new();
$gauls->pathfinder(1);

$travian->send_troops(Travian::ATTACK_RAID, $x, $y, $gauls, Travian::SCOUT_RESOURCES);

#$travian->logout();
