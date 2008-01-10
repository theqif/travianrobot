use lib '../lib/';
use Travian;

my $server = shift;

my $t   = Travian->new(3,);
my $url = $t->base_url . "map.sql";

my $date = `date +"%Y%m%d"`; chop $date;
my $out = "s${server}_map_${date}.csv";

&get_save($t->get($url)->content(), $out);

sub get_save
{
  my $p   = shift;
  my $out = shift;

  open (IN, ">>$out") || die "Can't open [$p] : [$!]";
   print IN $p;
  close IN
}
