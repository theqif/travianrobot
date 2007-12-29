#!/usr/bin/perl -w

use lib '../lib/';
use Travian qw(calc_traveltime);

my $x1 = shift;
my $y1 = shift;
my $x2 = shift;
my $y2 = shift;
my $v = shift;

die "usage: $0 [attacker_x] [attacker_y] [defender_x] [defender_y] [velocity]\n" unless $x1 && $y1 && $x2 && $y2 && $v;

my $seconds = &calc_traveltime($x1, $y1, $x2, $y2, $v);
print "Seconds: ";
print $seconds;
print "\n";
print "Minutes: ";
print $seconds / 60;
print "\n";


