#!/usr/bin/perl -w

use lib '../lib';
use Data::Dumper;
use Travian;
use strict;
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


my $f = shift || "all.csv";
open (A, $f) || die "Cant open [$f] : [$!]";

my $u_v_hr = ();

while (<A>)
{
  chomp;
  my $v_params = [];
  my $u_ar     = [split /,/,$_];

  #$u_ar->[0] UID
  #$u_ar->[1] name
  #$u_ar->[2] population
  #$u_ar->[3] rank
  #$u_ar->[4] villages
  #$u_ar->[5] tribe
  #$u_ar->[6] kartes

  if ($u_ar->[6] =~ m#\|#) { $v_params = [ split /\|/, $u_ar->[6] ]; }
  else                     { push @{$v_params}       , $u_ar->[6]; }

  $u_v_hr->{$u_ar->[0]} = $v_params;
}

foreach my $uid (keys %{$u_v_hr})
{
#print "[[$uid]]\n";
  foreach my $param (@{$u_v_hr->{$uid}})
  {
    my $url  = "http://s3.travian.co.uk/karte.php?d=" . $param;
#print "\t[$url]\n";

    my $page = $travian->get($url)->content();
    my $vill = &Travian::parse_village($page);

#print Dumper ($vill);

    next unless (defined ($vill->{x}));

    print join ",", map { $vill->{$_} || "" } qw/x y ttime/;
    print "\n";
  }
}
