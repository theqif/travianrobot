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
 '1200326970' => { tid=> 1, x=> 3, y=>34, tt=>20, name=>'junglejazza', },
 '2' => { tid=> 2, x=>33, y=>43, tt=>15, name=>'pipjrob',     },
 '3' => { tid=> 3, x=>22, y=>30, tt=>15, name=>'Aimee',       },
 '4' => { tid=> 4, x=>13, y=>46, tt=>15, name=>'Bomster',     },
 '5' => { tid=> 5, x=>10, y=>48, tt=>10, name=>'garner',      },
 '6' => { tid=> 6, x=> 7, y=>41, tt=> 5, name=>'Death',       },
 '7' => { tid=> 7, x=>14, y=>37, tt=>10, name=>'madeddy',     },
 '8' => { tid=> 8, x=>38, y=>49, tt=>15, name=>'naynay123',   },
 '9' => { tid=> 9, x=>28, y=>49, tt=>35, name=>'scarmace',    },
};

while (1)
{
  my $dt = time;

print "$0 : [$dt]\n";

  foreach my $rt (sort keys %{$attacks})
  {
    if ($rt < $dt)
    {
      if (!$t->logged_in)
      {
        warn "***loggin in again";
        croak $t->error_msg() unless ($t->login($user, $pass));
      }



      my $rep = &find_atak_report($t, $user, $attacks->{$rt}->{name});
      warn "***Can't find report of previous attack" unless ($rep);

      if ($rep)
      {
        if ($rep->is_max) { print "MAX!! - increase?\n" } else { print "Not max - decrease?\n"; }
#$attacks->{$rt}->{tt} += 5 if ($rep->is_max);
      }

      print "\t\tTime to raid [" . $attacks->{$rt}->{name} . "] again .. \n";
      my $return = &launch_atak ($t,$attacks->{$rt});

      while (exists $attacks->{$return}) { $return++; }
      print "\t\tReturn at : [$return]\n";

      $attacks->{$return} = $attacks->{$rt};
      delete $attacks->{$rt};
    }
    else { print "\t" . ($rt-$dt) . " secs until [" . $attacks->{$rt}->{name} . "] returns\n"; }
  }

  sleep 60;
}

sub launch_atak
{
  my $t  = shift;
  my $ap = shift;

  my $troop = Travian::Troops::Gauls->new();
     $troop->theutates_thunder($ap->{tt});

  $t->village('74134');

  if (!$t->send_troops(Travian::ATTACK_RAID, $ap->{x}, $ap->{y}, $troop))
  {
    warn "***".$t->error_msg;
    return 0;   
  }

  my $dt = time;
  my $ttime = int(&calc_traveltime(19,40, $ap->{x}, $ap->{y}, 19));
  return ($dt + $ttime + $ttime + 10);
}



sub find_atak_report
{
  my $t = shift;
  my $user   = shift || return undef;
  my $target = shift || return undef;
  my $i      = shift || 0;

print "\t\tSearching for [$target] reports, starting at [$i]\n";

  my $report_attacks = $t->report_headers(Travian::REPORT_ATTACKS,$i);

  foreach my $header (@{$report_attacks})
  {
    $i++;
    my $r = $t->report($header->id());

    croak "Cannot retrieve report " . $header->id() . "." unless ($r);

    next unless ($r->attacker()->name() eq $user);
    next unless ($r->defender()->name() eq $target);

    return $r;
  }
print "\t\t\ti - [$i]\n\n\n";
  if ($i % 10 == 0) { return &find_atak_report($t,$user,$target,$i); }
  return undef;
}
