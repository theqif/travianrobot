use lib '../lib';
use Data::Dumper;
use Travian;
use strict;
use Carp;

my $UA = "Mozilla/5.0 (Macintosh; U; Intel Mac OS X; en-US; rv:1.8.1.11) Gecko/20071127 Firefox/2.0.0.11";

my $server = shift;
my $vid    = shift;
my $user   = shift;
my $pass   = shift;
my $gid    = shift;
my $lvl    = shift;

die "usage: $0 [server] [vid] [user] [pass] [gid] [target_lvl]\n" unless $server && $vid  && $user && $pass && $gid && $lvl;

my $t = Travian->new($server, agent => $UA);

if (!$t->login($user, $pass))
{
        croak $t->error_msg();
}

$t->village($vid);

my $existing_lvl = 0;

foreach my $b (@{$t->village->buildings})
{
  next unless ($b->gid eq $gid);
  $existing_lvl = $b->level;
}

print "Want [$lvl] Have [$existing_lvl]\n";

my $construction = $t->construction($gid);

print "GID:  " . $construction->gid() . "\n";
print "Name: " . $construction->name(). "\n";

my $need = ();

foreach (($existing_lvl+1)..$lvl)
{
  my $cost = $construction->costs($_);

  foreach (qw/wood clay iron wheat/)
  {
    $need->{$_} += $cost->$_;
  }

  #$need->{wood}  += $cost->wood;
  #$need->{clay}  += $cost->clay;
  #$need->{iron}  += $cost->iron;
  #$need->{wheat} += $cost->wheat;
}

print Dumper ($need);
exit;
print '-------------';
print "\n";

my $total_cost = $construction->total_cost();
print "Total Cost\t";
print "Wood: " . $total_cost->wood() . "\t";
print "Clay: " . $total_cost->clay() . "\t";
print "Iron: " . $total_cost->iron() . "\t";
print "Wheat: " . $total_cost->wheat() . "\t";
print "Wheat (Consumption): " . $total_cost->wheat_consumption() . "\t";
print "CP: " . $total_cost->culture_points() . "\t";
print "\n\n";

for ($lvl = 1; $lvl <= $construction->max_lvl(); $lvl++)
{
	print "Level: $lvl\t";
	for (my $mb_lvl = 1; $mb_lvl <= 20; $mb_lvl++)
	{
		print "MB $mb_lvl: ";
		print $construction->times($lvl, $mb_lvl);
		print "\t";
	}
	print "\n";
}

