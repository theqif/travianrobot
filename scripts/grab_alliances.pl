#!/usr/bin/perl -w

use lib '../lib';
use Data::Dumper;
use Travian;
use Carp;

my $server = shift;
my $user   = shift;
my $pass   = shift;
my $from   = shift;
my $to     = shift;

die "usage: $0 [server] [user] [pass] [from] [to]\n" unless $server && $user && $pass && $from && $to;

my $USERAGENT = 'Mozilla/5.0 (X11; U; Linux x86_64; en-GB; rv:1.8.1.11) Gecko/20071204 Ubuntu/7.10 (gutsy) Firefox/2.0.0.11';

my $travian = Travian->new($server, agent => $USERAGENT);

if (!$travian->login($user, $pass))
{
        croak $travian->error_msg();
}

my $a_url = "http://s3.travian.co.uk/allianz.php?aid=";

foreach my $aid ($from..$to)
{
  my $page = $travian->get($a_url . $aid)->content();

  my $alliance = &Travian::parse_alliance($page);

  next unless (defined ($alliance->{name}));

  $alliance->{id} = $aid;
print Dumper ($alliance);

  print join ",", map { $alliance->{$_} || "" } qw/id name nmembers rank tag allies members/;
  print "\n";
}
