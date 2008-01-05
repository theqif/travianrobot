use lib '../lib';

use Data::Dumper;
use Travian;
use strict;
use Carp;

my $UA = "Mozilla/5.0 (Macintosh; U; Intel Mac OS X; en-US; rv:1.8.1.11) Gecko/20071127 Firefox/2.0.0.11";

my $server = shift();
my $vid    = shift();
die "Usage : $0 [server] [vid]\n" unless $server && $vid;

my $t   = Travian->new($server, agent => $UA);

my $data = ();

foreach (@{&available_map_data($server)})
{
  $_ =~ m#_(\d\d\d\d\d\d).csv#;
  my $date = $1;
  my $map = &slurp_file($_);

  $data->{$date} = $t->parse_map_data($map,19,40);
}

foreach my $day (keys %{$data})
{
  foreach my $player (@{$data->{$day}})
  {
    next unless ($player->{vid} == $vid);
    print Dumper ($player);
  }
}

#print Dumper ($data);


sub available_map_data
{
  my $s = shift || return [];

  my $glob = "../data/s${s}_*.csv";

  return [glob $glob];
}

sub slurp_file
{
  my $f = shift; my $map = "";
  open (IN, $f) || croak "Cannot open [$f] : [$!]\n";
  while (<IN>) { $map .= $_; }
  close IN;
  return $map;
}
