#!/usr/bin/perl -w

use lib '../lib/';

use Travian;

my $gid = shift;
die "usage: $0 [gid]\n" unless $gid;

my $USERAGENT = "Mozilla/5.0 (Macintosh; U; Intel Mac OS X; en-US; rv:1.8.1.11) Gecko/20071127 Firefox/2.0.0.11";

my $travian = Travian->new();

my $construction = $travian->construction($gid);

print "GID: ";
print $construction->gid();
print "\n";
print "Name: ";
print $construction->name();
print "\n";

my $lvl = 1;
foreach my $cost (@{$construction->costs()})
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

my $total_cost = $construction->total_cost();
print "Total Cost\t";
print "Wood: " . $total_cost->wood() . "\t";
print "Clay: " . $total_cost->clay() . "\t";
print "Iron: " . $total_cost->iron() . "\t";
print "Wheat: " . $total_cost->wheat() . "\t";
print "Wheat (Consumption): " . $total_cost->wheat_consumption() . "\t";
print "CP: " . $total_cost->culture_points() . "\t";
print "\n\n";

for ($lvl = 1; $lvl <= $construction->max_lvl(); $lvl++)
{
	print "Level: $lvl\t";
	for (my $mb_lvl = 1; $mb_lvl <= 20; $mb_lvl++)
	{
		print "MB $mb_lvl: ";
		print $construction->times($lvl, $mb_lvl);
		print "\t";
	}
	print "\n";
}

