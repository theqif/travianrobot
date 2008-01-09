#!/usr/bin/perl -w

use lib '../lib/';

use Travian;

my $TROOP_TYPE = Travian::TRIBE_TYPE_NATURE;

my $USERAGENT = 'Mozilla/5.0 (X11; U; Linux x86_64; en-GB; rv:1.8.1.11) Gecko/20071204 Ubuntu/7.10 (gutsy) Firefox/2.0.0.11';
#my $USERAGENT = "Mozilla/5.0 (Macintosh; U; Intel Mac OS X; en-US; rv:1.8.1.11) Gecko/20071127 Firefox/2.0.0.11";

my $travian = Travian->new(3, agent => $USERAGENT);

my $troop_attributes = $travian->troop_attributes($TROOP_TYPE);
foreach my $attributes (@{$troop_attributes->attributes()})
{
	print $attributes->attack();
	print "\t";
	print $attributes->defence_infantry();
	print "\t";
	print $attributes->defence_cavalry();
	print "\t";
	print $attributes->cost()->wood();
	print "\t";
	print $attributes->cost()->clay();
	print "\t";
	print $attributes->cost()->iron();
	print "\t";
	print $attributes->cost()->wheat();
	print "\t";
	print $attributes->cost()->wheat_consumption();
	print "\t";
	print $attributes->velocity();
	print "\n";
}

#print $troop_attributes->theutates_thunder_attributes()->velocity();
#print "\n";

