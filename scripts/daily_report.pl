use strict;
use Data::Dumper;
use lib '../lib';

my $UA = "Mozilla/5.0 (Macintosh; U; Intel Mac OS X; en-US; rv:1.8.1.11) Gecko/20071127 Firefox/2.0.0.11";

use Travian;

my $t = Travian->new(shift(), agent => $UA);

if (!$t->login(shift(), shift()))
{
        croak $t->error_msg();
}

my $hr = &parse_user_logs(shift(),shift());

foreach (values %{$hr})
{
#  if ($_->{is} eq $_->{was}) { print "same : [$_->{id}\n"; }
#  if ($_->{is} gt $_->{was}) { print "grew : [$_->{id}- $_->{vl}\n"; }
#  if ($_->{is} lt $_->{was}) { print "dies : [$_->{id}\n"; }

  next unless ($_->{is} eq $_->{was});

  my $vp   = [split /\|/, $_->{vl}];
  my $res = [ sort { $a->{ttime} gt $b->{ttime}  } map { $t->get_vill($_) } @{$vp} ];

}

#my $file = do { local $/; <FILE> };
sub slurp
{
  local $/ = undef;
  open (AA, shift()) || die "fish : $!";
  my $aa = <AA>;
  close AA;
  return $aa;
}

sub parse_user_logs
{
  my $hr;
  foreach (split /\n/, &slurp(shift))
  {
  #my($time,$load,$buff,$free) = (split /,/)[0,1,3,10];
    my    $id         = [split /,/]->[0];
    $hr->{$id}->{was} = [split /,/]->[2];
  }

  foreach (split /\n/, &slurp(shift))
  {
    my    $id         = [split /,/]->[0];
    $hr->{$id}->{is}  = [split /,/]->[2];
    $hr->{$id}->{vl}  = [split /,/]->[7];
    $hr->{$id}->{id}  = $id;
  }

  return $hr;
}

