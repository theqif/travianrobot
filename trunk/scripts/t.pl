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

print Dumper ($t->get_current_build_levels());
