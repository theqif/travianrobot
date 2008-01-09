#!/usr/bin/perl -w

use lib '../lib';
use Travian;
use Carp;

my $server = shift;
my $user = shift;
my $pass = shift;
my $uid = shift;

die "usage: $0 [server] [user] [pass] [uid]\n" unless $server && $user && $pass && $uid;

my $USERAGENT = 'Mozilla/5.0 (X11; U; Linux x86_64; en-GB; rv:1.8.1.11) Gecko/20071204 Ubuntu/7.10 (gutsy) Firefox/2.0.0.11';
#my $USERAGENT = "Mozilla/5.0 (Macintosh; U; Intel Mac OS X; en-US; rv:1.8.1.11) Gecko/20071127 Firefox/2.0.0.11";

my $travian = Travian->new($server, agent => $USERAGENT);

if (!$travian->login($user, $pass))
{
	croak $travian->error_msg();
}

my $profile = $travian->profile($uid);

print "Player ID: ";
print $profile->player_id();
print "\n";
print "Player Name: ";
print $profile->player_name();
print "\n";
print "Rank: ";
print $profile->rank();
print "\n";
print "Tribe: ";
print $profile->tribe();
print "\n";
print "Alliance: ";
print $profile->alliance();
print "\n";
print "Population: ";
print $profile->population();
print "\n";

