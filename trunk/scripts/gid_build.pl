#!/usr/bin/perl -w

use lib '../lib';
use Data::Dumper;
use Travian;
use strict;
use Carp;

#my $UA = 'Mozilla/5.0 (X11; U; Linux x86_64; en-GB; rv:1.8.1.11) Gecko/20071204 Ubuntu/7.10 (gutsy) Firefox/2.0.0.11';
my $UA = "Mozilla/5.0 (Macintosh; U; Intel Mac OS X; en-US; rv:1.8.1.11) Gecko/20071127 Firefox/2.0.0.11";

my $server = shift;
my $vid    = shift;
my $user   = shift;
my $pass   = shift;
my $gid    = shift;
my $lvl    = shift;

die "usage: $0 [server] [vid] [user] [pass] [gid] [target_lvl]\n" unless $server && $vid  && $user && $pass && $gid && $lvl;

my $t = Travian->new($server, agent => $UA);

if (!$t->login($user, $pass))
{
        croak $t->error_msg();
}

$t->village($vid);

my $mb           = $t->village()->main_building_level();
my $existing_lvl = $t->village()->building_level_from_gid($gid);
my $construction = $t->construction($gid);

print "GID:  " . $construction->gid() . "\n";
print "Name: " . $construction->name(). "\n";
print "Existing level : [$existing_lvl]\n";
print "Desired  level : [$lvl]\n";

my $need = ();

foreach (($existing_lvl+1)..$lvl)
{
  my $cost = $construction->costs($_);
  foreach (qw/wood clay iron wheat/)
  {
    $need->{$_} += $cost->$_;
  }

  $need->{time} += $construction->times($_, $mb);
}

print "Wood needs  " . $need->{wood}  . " at ". $t->village->production_wood  . " : " . int ($need->{wood} /$t->village->production_wood)  . " hours\n";
print "Clay needs  " . $need->{clay}  . " at ". $t->village->production_clay  . " : " . int ($need->{clay} /$t->village->production_clay)  . " hours\n";
print "Iron needs  " . $need->{iron}  . " at ". $t->village->production_iron  . " : " . int ($need->{iron} /$t->village->production_iron)  . " hours\n";
print "Wheat needs " . $need->{wheat} . " at ". $t->village->production_wheat . " : " . int ($need->{wheat}/$t->village->production_wheat) . " hours\n";

print "Total build time : " . $need->{time} . " seconds / " . int ($need->{time}/60) . " mins / " . int ($need->{time}/3600) . " hours\n";

exit;
