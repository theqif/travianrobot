#!/usr/bin/perl -w

use lib '../lib';
use Travian;
use Carp;

my $user = shift;
my $pass = shift;

die "usage: $0 [user] [pass]\n" unless $user && $pass;

my $travian = Travian->new(4);
if (!$travian->login($user, $pass))
{
	croak $travian->error_msg();
}

print "Village Name: " . $travian->village()->village_name() . "\n";
print "Wood: " . $travian->village()->current_wood() . '/' . $travian->village()->max_wood() . ' (' . $travian->village()->production_wood() . ")\n";
print "Clay: " . $travian->village()->current_clay() . '/' . $travian->village()->max_clay() . ' (' . $travian->village()->production_clay() . ")\n";
print "Iron: " . $travian->village()->current_iron() . '/' . $travian->village()->max_iron() . ' (' . $travian->village()->production_iron() . ")\n";
print "Wheat: " . $travian->village()->current_wheat() . '/' . $travian->village()->max_wheat() . ' (' . $travian->village()->production_wheat() . ")\n";
print "Wheat (Consumption): " . $travian->village()->current_wheat_consumption() . '/' . $travian->village()->max_wheat_consumption() . "\n";

$travian->logout();

