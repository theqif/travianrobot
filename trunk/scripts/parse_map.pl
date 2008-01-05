use lib '../lib';

use Data::Dumper;
use Travian;
use strict;
use Carp;

my $UA = "Mozilla/5.0 (Macintosh; U; Intel Mac OS X; en-US; rv:1.8.1.11) Gecko/20071127 Firefox/2.0.0.11";

my $server = shift() || die "Usage : $0 [server]\n";

my $t   = Travian->new(shift(), agent => $UA);
my $url = $t->base_url . "map.sql";
my $res = $t->get($url);
my $p = $res->content();

croak "Error downloading [$url]\n" unless ($res->is_success);

print Dumper (&parse_map_data($p));


sub parse_map_data
{
  my $hr = ();
  foreach my $row (split /\n/, shift())
  {
    $row =~ s/INSERT INTO `x_world` VALUES \(//; $row =~ s/\);//;

    my ($id, $x, $y, $pop) = ( split /,/, $row )[0,1,2,10];

    $hr->{$id} = { x=>$x, y=>$y, pop=>$pop, };
  }
  return $hr;
}

#id 	Number of the field, starts in the top left corner at the coordinate (-400|400) and ends in the bottom right corner at (400|-400)
#x 	X-Coordinate
#y 	y-Coordinate
#tid 	The tribe number. 1 = Roman, 2 = Teuton, 3 = Gaul, 4 = Nature and 5 = Natars
#vid 	Village number
#village 	Village name
#uid 	Player number also known as User-ID
#player 	Player name
#aid 	Alliance number
#alliance 	Alliance name
#population 	The village's number of inhabitants
