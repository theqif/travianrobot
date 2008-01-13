#!/usr/bin/perl -w

use lib '../lib';
use Travian (qw/calc_traveltime/);
use Travian::Troops::Gauls;
use Carp;
use Data::Dumper;

my $server = shift;
my $user = shift;
my $pass = shift;

my $t = Travian->new($server);

croak $t->error_msg() unless ($t->login($user, $pass));

my $returns =
{
 '1' => {x=> 3,y=>34,tt=>20,name=>'junglejazza'},
 '2' => {x=>33,y=>43,tt=>15,name=>'pipjrob'},
};

while (1)
{
  my $dt = time;

print "DT - [$dt]\n";
print Dumper ($returns);

  foreach my $rt (keys %{$returns})
  {
    if ($rt < $dt)
    {
      print "\t\tCOOL - time to raid again .. \n";
      my $ap = $returns->{$rt};
      my $return = &launch_atak ($t,$ap);

      $returns->{$return} = $ap;
      delete $returns->{$rt};
    }
    else { print "Still waiting for " . $returns->{$rt}->{name} . "to get back\n"; }
  }

  sleep 10;
}

sub launch_atak
{
  my $t  = shift;
  my $ap = shift;

  my $troop = Travian::Troops::Gauls->new();
     $troop->theutates_thunder($ap->{tt});

#  croak $t->error_msg() unless ($t->send_troops(Travian::ATTACK_RAID, $ap->{x}, $ap->{y}, $troop));

  my $dt = time;
  my $ttime = int(&calc_traveltime(19,40, $ap->{x}, $ap->{y}, 19));
  return ($dt + $ttime + $ttime + 10);
}
