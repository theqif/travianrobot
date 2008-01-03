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

my $u_url = "http://s3.travian.co.uk/spieler.php?uid=";

foreach my $uid ($from..$to)
{
  my $page = $travian->get($u_url . $uid)->content();

  my $play = &Travian::parse_user($page);

  next unless (defined ($play->{name}));

  $play->{id} = $uid;

  print join ",", map { $play->{$_} || "" } qw/id name population rank villages tribe aid vill_kid/;
  print "\n";
}
