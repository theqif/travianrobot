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

my $attacks =
{
 '1' => {x=> 3,y=>34,tt=>20,name=>'junglejazza'},
 '2' => {x=>33,y=>43,tt=>15,name=>'pipjrob'},
};

while (1)
{
  my $dt = time;

print "DT - [$dt]\n";
#print Dumper ($attacks);

  foreach my $rt (keys %{$attacks})
  {
    if ($rt < $dt)
    {
      my $rep = &find_atak_report($t, $user, $attacks->{$rt}->{name});

      warn "Can't find report of previous attack" unless ($rep);

#$attacks->{$rt}->{tt} += 5 if (&is_max($rep));
#$attacks->{$rt}->{tt} += 5 if ($rep->is_max);
#print Dumper ($attacks->{$rt});
#sub is_max { return 0; }

      if ($rep->is_max) { print "MAX!! - increase?\n" } else { print "Not max - decrease?\n"; }

      print "\t\tTime to raid [" . $attacks->{$rt}->{name} . "] again .. \n";
      my $return = &launch_atak ($t,$attacks->{$rt});

      while (exists $attacks->{$return}) { $return++; }
      print "\t\tReturn at : [$return]\n";

      $attacks->{$return} = $attacks->{$rt};
      delete $attacks->{$rt};
    }
    else { print "Still waiting for [" . $attacks->{$rt}->{name} . "] to get back\n"; }
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
return $dt + 30;
  return ($dt + $ttime + $ttime + 10);
}



sub find_atak_report
{
  my $t = shift;
  my $user   = shift || return undef;
  my $target = shift || return undef;
  my $i      = shift || 0;

print "Searching for reports, dtarting at [$i]\n";

  my $report_attacks = $t->report_headers(Travian::REPORT_ATTACKS,$i);

  foreach my $header (@{$report_attacks})
  {
    $i++;
    my $r = $t->report($header->id());

    croak "Cannot retrieve report " . $header->id() . "." unless ($r);

    print "atak : [" . $r->attacker->name . "]\tdefs : [" . $r->defender->name . "]\n";

    next unless ($r->attacker()->name() eq $user);
    next unless ($r->defender()->name() eq $target);

    return $r;
  }
print "i - [$i]\n\n\n";
  if ($i % 10 == 0) { return &find_atak_report($t,$user,$target,$i); }
  return undef;
}
