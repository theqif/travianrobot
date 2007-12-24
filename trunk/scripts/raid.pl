#!/usr/bin/perl -w

use lib '../lib/';
use Travian;
use Travian::Troops::Gauls;

my $user = shift;
my $pass = shift;
my $x = shift;
my $y = shift;
my $tt = shift;

die "usage: $0 [user] [pass] [x] [y] [th_thunder]\n" unless $user && $pass && $x && $y && $tt;

my $travian = Travian->new();
if (!$travian->login($user, $pass))
{
	croak $travian->error_msg();
}

my $gauls = Travian::Troops::Gauls->new();
$gauls->theutates_thunder($tt);

$travian->send_troops(Travian::ATTACK_RAID, $x, $y, $gauls);

#$travian->logout();
