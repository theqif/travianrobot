#!/usr/bin/perl -w

use lib '../lib';
use Travian;
use Carp;

my $server = shift;
my $user = shift;
my $pass = shift;

die "usage: $0 [server] [user] [pass]\n" unless $server && $user && $pass;

my $USERAGENT = 'Mozilla/5.0 (X11; U; Linux x86_64; en-GB; rv:1.8.1.11) Gecko/20071204 Ubuntu/7.10 (gutsy) Firefox/2.0.0.11';
#my $USERAGENT = "Mozilla/5.0 (Macintosh; U; Intel Mac OS X; en-US; rv:1.8.1.11) Gecko/20071127 Firefox/2.0.0.11";

my $travian = Travian->new($server, agent => $USERAGENT);

my $args = {};
$args->{get}->{user} = $user;
$args->{get}->{pass} = $pass;

if (!$travian->mdr_login($args))
{
	croak $travian->error_msg();
}

for (my $village_no = 1; $village_no <= $travian->no_of_villages(); $village_no++)
{
	print "Village Name: " . $travian->village()->village_name() . "\n";
	print "Wood: " . $travian->village()->current_wood() . '/' . $travian->village()->max_wood() . ' (' . $travian->village()->production_wood() . ")\n";
	print "Clay: " . $travian->village()->current_clay() . '/' . $travian->village()->max_clay() . ' (' . $travian->village()->production_clay() . ")\n";
	print "Iron: " . $travian->village()->current_iron() . '/' . $travian->village()->max_iron() . ' (' . $travian->village()->production_iron() . ")\n";
	print "Wheat: " . $travian->village()->current_wheat() . '/' . $travian->village()->max_wheat() . ' (' . $travian->village()->production_wheat() . ")\n";
	print "Wheat (Consumption): " . $travian->village()->current_wheat_consumption() . '/' . $travian->village()->max_wheat_consumption() . "\n";
	print "\n";

	$travian->next_village();
}

#$travian->logout();

