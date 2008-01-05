use lib '../lib';
use Data::Dumper;
use Travian;
use strict;
use Carp;

my $UA = "Mozilla/5.0 (Macintosh; U; Intel Mac OS X; en-US; rv:1.8.1.11) Gecko/20071127 Firefox/2.0.0.11";

my $server = shift;
my $user   = shift;
my $pass   = shift;
my $fvid   = shift;
my $tx     = shift;
my $ty     = shift;

my $w = shift; my $c = shift; my $i = shift; my $wh = shift;

#perl send_resources.pl 3 theqif fish 74134 19 41 50 50 50 50
die "usage: $0 [server] [user] [pass] [from_vid] [to_x][to_y] [wood][clay][iron][wheat]\n" unless $server && $user && $pass && $fvid && $tx && $ty && $w&&$c&&$i&&$wh;


my $t = Travian->new($server, agent => $UA);

if (!$t->login($user, $pass))
{
        croak $t->error_msg();
}


my $url = $t->base_url . "build.php";

#id=>19 is set - refers to the city square where the merchants are based - not sure _why_
my $ar  = [id=>19, dname=>"", x=>$tx, y=>$ty, x2=>'', r1=>$w, r2=>$c, r3=>$i, r4=>$wh, s1=>'ok', ];

$t->village($fvid);
my $res = $t->post($url, $ar);

croak "Couldnt post : " . Dumper ($res) unless ($res->is_success);

my $car = &confirm_merchant_send($t,$res->content());

#can get duration & nMerchants from $car now .. but how?
#unshift (@{$car}); unshift (@{$car}); unshift (@{$car}); unshift (@{$car});
#print Dumper ($car); exit;

my $cres = $t->post($url, $car);

croak "Couldnt confirm : " . Dumper ($cres) unless ($cres->is_success);

print "Done!\n";

sub confirm_merchant_send
{
  my $s = shift;
  my $p = shift;

  my ($a,$sz,$kid);
  if ($p =~ m#name="a" value="(\d+?)"#msg) { $a   = $1; }
  if ($p =~ m#ame="sz" value="(\d+?)"#msg) { $sz  = $1; }
  if ($p =~ m#me="kid" value="(\d+?)"#msg) { $kid = $1; }

  my ($r1,$r2,$r3,$r4);
  if ($p =~ m#name="r1" value="(\d+?)"#msg) { $r1 = $1; }
  if ($p =~ m#name="r2" value="(\d+?)"#msg) { $r2 = $1; }
  if ($p =~ m#name="r3" value="(\d+?)"#msg) { $r3 = $1; }
  if ($p =~ m#name="r4" value="(\d+?)"#msg) { $r4 = $1; }


  my ($dur, $mer);
  if ($p =~ m#<td>Duration:</td><td>(\d:\d\d:\d\d)</td>#msg) { $dur = $1; }
  if ($p =~ m#<td>Merchants:</td><td>(\d+?)</td>#msg)        { $mer = $1; }

  return [id=>19, r1=>$r1, r2=>$r2, r3=>$r3, r4=>$r4, x2=>'', s1=>'ok', a=>$a, sz=>$sz, kid=>$kid, dur=>$dur, mer=>$mer];
}
