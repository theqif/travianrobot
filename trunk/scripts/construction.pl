#!/usr/bin/perl -w

use lib '../lib/';

use Travian;

my $gid = shift;
die "usage: $0 [gid]\n" unless $gid;

my $travian = Travian->new();

my $woodcutter = $travian->construction($gid);

print "GID: ";
print $woodcutter->gid();
print "\n";
print "Name: ";
print $woodcutter->name();
print "\n";

my $lvl = 1;
foreach my $cost (@{$woodcutter->costs()})
{
	print "Level: $lvl\t";
	print "Wood: " . $cost->wood() . "\t";
	print "Clay: " . $cost->clay() . "\t";
	print "Iron: " . $cost->iron() . "\t";
	print "Wheat: " . $cost->wheat() . "\t";
	print "Wheat (Consumption): " . $cost->wheat_consumption() . "\t";
	print "CP: " . $cost->culture_points() . "\t";
	print "\n";

	$lvl++;
}

print '-------------';
print "\n";

my $total_cost = $woodcutter->total_cost();
print "Total Cost\t";
print "Wood: " . $total_cost->wood() . "\t";
print "Clay: " . $total_cost->clay() . "\t";
print "Iron: " . $total_cost->iron() . "\t";
print "Wheat: " . $total_cost->wheat() . "\t";
print "Wheat (Consumption): " . $total_cost->wheat_consumption() . "\t";
print "CP: " . $total_cost->culture_points() . "\t";
print "\n";


