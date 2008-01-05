use lib '../lib';

use Data::Dumper;
use Travian;
use strict;
use Carp;

my $UA = "Mozilla/5.0 (Macintosh; U; Intel Mac OS X; en-US; rv:1.8.1.11) Gecko/20071127 Firefox/2.0.0.11";

my $server = shift() || die "Usage : $0 [server]\n";

my $t   = Travian->new($server, agent => $UA);

#my $map = $t->get_latest_map;
#my $hr = $t->parse_map_data($map,19,40);

#print Dumper ($hr);

my $data = ();

foreach (@{&available_map_data($server)})
{
  $_ =~ m#_(\d\d\d\d\d\d\d\d).csv#;
  my $date = $1; print $1 . "\n";
  my $map = &slurp_file($_);

  $data->{$date} = $t->parse_map_data($map,19,40);
}

print Dumper ($data);


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
