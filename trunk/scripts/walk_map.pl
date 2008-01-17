#!/usr/bin/perl -w

use lib '../lib';
use Travian;
use Carp;
use Data::Dumper;

my $server = shift; my $user = shift; my $pass = shift;
die "$0 : Need server, user & pass" unless ($server && $user && $pass);

my $t = Travian->new($server);
croak $t->error_msg() unless ($t->login($user, $pass));

#my $params = &slurp_karte_params;
my $params = [qw/d=287177&c=f1 d=286378&c=fe d=287178&c=ac d=287179&c=65/];

#d=287177&c=f1 : Occupied village #d=286378&c=fe : Unoccupied village
#d=287178&c=ac : Unoccupied Oasis #d=287179&c=65 : Occupied Oasis

my $villages =
{
  1 => '3 wood, 3 clay, 3 iron,  9 crop',
  2 => '3 wood, 4 clay, 5 iron,  6 crop',
  3 => '4 wood, 4 clay, 4 iron,  6 crop',
  4 => '4 wood, 5 clay, 3 iron,  6 crop',
  5 => '5 wood, 3 clay, 4 iron,  6 crop',
  6 => '1 wood, 1 clay, 1 iron, 15 crop',
};

my $field_types =
{
  1 =>
  {
     1 => 'crop',  2 => 'crop',  3 => 'wood',  4 => 'crop',  5 => 'crop',  6 => 'clay',
     7 => 'iron',  8 => 'crop',  9 => 'crop', 10 => 'iron', 11 => 'iron', 12 => 'crop',
    13 => 'crop', 14 => 'wood', 15 => 'crop', 16 => 'clay', 17 => 'wood', 18 => 'clay',
  },
  2 =>
  {
     1 => 'iron',  2 => 'crop',  3 => 'wood',  4 => 'iron',  5 => 'clay',  6 => 'clay',
     7 => 'iron',  8 => 'crop',  9 => 'crop', 10 => 'iron', 11 => 'iron', 12 => 'crop',
    13 => 'crop', 14 => 'wood', 15 => 'crop', 16 => 'clay', 17 => 'wood', 18 => 'clay',
  },
  3 =>
  {
     1 => 'wood',  2 => 'crop',  3 => 'wood',  4 => 'iron',  5 => 'clay',  6 => 'clay',
     7 => 'iron',  8 => 'crop',  9 => 'crop', 10 => 'iron', 11 => 'iron', 12 => 'crop',
    13 => 'crop', 14 => 'wood', 15 => 'crop', 16 => 'clay', 17 => 'wood', 18 => 'clay',
  },
  4 =>
  {
     1 => 'wood',  2 => 'crop',  3 => 'wood',  4 => 'clay',  5 => 'clay',  6 => 'clay',
     7 => 'iron',  8 => 'crop',  9 => 'crop', 10 => 'iron', 11 => 'iron', 12 => 'crop',
    13 => 'crop', 14 => 'wood', 15 => 'crop', 16 => 'clay', 17 => 'wood', 18 => 'clay',
  },
  5 =>
  {
     1 => 'wood',  2 => 'crop',  3 => 'wood',  4 => 'iron',  5 => 'wood',  6 => 'clay',
     7 => 'iron',  8 => 'crop',  9 => 'crop', 10 => 'iron', 11 => 'iron', 12 => 'crop',
    13 => 'crop', 14 => 'wood', 15 => 'crop', 16 => 'clay', 17 => 'wood', 18 => 'clay',
  },
  6 =>
  {
     1 => 'crop',  2 => 'crop',  3 => 'wood',  4 => 'iron',  5 => 'crop',  6 => 'crop',
     7 => 'crop',  8 => 'crop',  9 => 'crop', 10 => 'crop', 11 => 'crop', 12 => 'crop',
    13 => 'crop', 14 => 'crop', 15 => 'crop', 16 => 'clay', 17 => 'crop', 18 => 'crop',
  },
};

my $oases =
{
   3 => 'wood, crop',  6 => 'clay, crop',
   9 => 'iron, crop', 12 => 'crop, crop',
   1 => 'wood',        2 => 'wood',
   4 => 'clay',        5 => 'clay',
   7 => 'iron',        8 => 'iron',
  10 => 'crop',       11 => 'crop',
};

foreach my $p (@{$params})
{
  my $url = "http://s3.travian.co.uk/karte.php?" . $p;
  my $con = $t->get($url)->content;
  print "[$url]\n";

  my $uid = undef;
  my $xy  = undef;

  if ($con =~ m#<h1>.+? \((-*\d+?\|-*\d+?)\)<\/h1>#mgs)
  {
    $xy = $1;
  }

  if ($con =~ m#<div id="f(\d+?)">#mgs  )
  {
    print "\tVillage - $villages->{$1}\n";
    if    ($con =~ m#Unoccupied valley#mgs) {}
    else
    {
      if ($con =~ m#"spieler.php\?uid=(\d+?)"#mgs) { $uid = $1; }
    }
  }
  elsif ($con =~ m#img/un/m/w(\d+?).jpg#mgs)
  {
    print "\tOasis   - $oases->{$1}\n";
    if    ($con =~ m#Unoccupied valley#mgs) {}
    else 
    { 
      if ($con =~ m#"spieler.php\?uid=(\d+?)"#mgs) { $uid = $1; }
    }
  }
  else
  {
    warn "*** dont know what todo with [$url]";
    next;
  }
  print "\t\t[$xy],[$uid]\n";
}


sub slurp_karte_params
{
  my $ar = [];
  open (IN, "../data/s3_all_karte_params") || croak "$0 : Cannot open : [$!]";
  while (<IN>)
  {
    chomp; push @{$ar}, $_;
  }
  close IN;
  return $ar;
}
