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

my $url = $t->base_url . "allianz.php?s=3";

my $p   = $t->get($url)->content();
my $ar  = [ $p =~ m#berichte.php\?id=(\d+?)"#msg ];

foreach my $rid (@{$ar})
{
  # call report parsing routine ..
  # filter on alliance members outgoing only ..
  # remove self from report

}


my $data=<<EODATA;
<tr>
<td><img src="img/un/a/att_all.gif" border="0"></td>
<td class="s7"><a href="berichte.php?id=1906280">theqif attacks scarmace</a></td>
<td class="c f8">FFH-B {N - =GOW=</td>
<td width="110">08.01.08 07:33</td>
</tr>
</tr>
<tr>
<td><img src="img/un/a/att_all.gif" border="0"></td>
<td class="s7"><a href="berichte.php?id=1906080">theqif scouts truthpoop</a></td>
<td class="c f8">FFH-B {N - </td>
<td width="110">08.01.08 07:16</td>
</tr>
EODATA
