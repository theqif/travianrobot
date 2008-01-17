#!/usr/bin/perl -w

use lib '../lib';
use Travian;
use Carp;
use Data::Dumper;

my $server = shift;
my $user = shift;
my $pass = shift;

my $t = Travian->new($server);
croak $t->error_msg() unless ($t->login($user, $pass));

#(1..641601)
my $z = 1;

my $params = ();

while ($z < 641601)
{
  my $url = "http://s3.travian.co.uk/karte2.php?z=" . $z;
  my $page = $t->get($url)->content;

  my $urls = [ $page =~ m#karte.php\?(d=\d+?&c=..)#mgs ];

  foreach (@{$urls}) { $params->{$_} = 1; }

  $z += 12;
}

foreach my $k (keys %{$params})
{
  print $k . "\n";
}
