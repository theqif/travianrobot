use lib '../lib';
use Data::Dumper;
use Travian;
use strict;
use Carp;

my $UA = "Mozilla/5.0 (Macintosh; U; Intel Mac OS X; en-US; rv:1.8.1.11) Gecko/20071127 Firefox/2.0.0.11";

my $server = shift;
my $user   = shift;
my $pass   = shift;

die "usage: $0 [server] [user] [pass]\n" unless $server && $user && $pass;

my $t = Travian->new($server, agent => $UA);

if (!$t->login($user, $pass))
{
        croak $t->error_msg();
}


my $url = $t->base_url . "dorf1.php";
my $p   = $t->get($url)->content();

my $arrival = "";

if ($p =~ m#att1.gif#msg)
{
  print "ATAK coming\n";
  $p =~ m#id=timer1>(\d:\d\d:\d\d)</span>#msg;
  $arrival = $1;
  print "due in " . $arrival . " hours\n";
}
else
{
print "SAFE\n";
}
