#!/usr/bin/perl -w

use lib '../lib/';

use Travian;

my $gid = shift or die "usage: $0 [gid]\n";

my $USERAGENT = "Mozilla/5.0 (Macintosh; U; Intel Mac OS X; en-US; rv:1.8.1.11) Gecko/20071127 Firefox/2.0.0.11";

$gid = 1;

my $travian = Travian->new();
my $ct = {};


my $woodcutter = $travian->construction($gid);


#each gid has $cl (construction level) 1..$max_cl
# each $cl has 20 construction times - 1 per MB level
#  will ignore 'SUM' values as you _never ever_ stick with same MB level throughout a construction.

my @tabs;
my $p = $travian->get("http://help.travian.co.uk/index.php?type=faq&gid=$gid")->content();

$p =~ m#<b>Building constructiontimes 1-10</b>(.+?)</table>#msg;  push @tabs, $1;
$p =~ m#<b>Building constructiontimes 11-20</b>(.+?)</table>#msg; push @tabs, $1;


foreach my $tab (@tabs)
{
  foreach my $tr ($tab =~ m#<tr.+?>(.+?)</tr>#msg)
  {
    next unless ($tr =~ /^(\d+)</);
    my $cl = $1;

    push @{$ct->{$gid}->{$cl}}, ($tr =~ m#<td>(.+?)</td>#msg);
  }
}

use Data::Dumper;
print Dumper ($ct);
