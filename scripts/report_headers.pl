#!/usr/bin/perl -w

use lib '../lib/';
use Travian;
use Carp;

my $server = shift;
my $user = shift;
my $pass = shift;

die "usage: $0 [server] [user] [pass]\n" unless $server && $user && $pass;

my $USERAGENT = 'Mozilla/5.0 (X11; U; Linux x86_64; en-GB; rv:1.8.1.11) Gecko/20071204 Ubuntu/7.10 (gutsy) Firefox/2.0.0.11';
#my $USERAGENT = "Mozilla/5.0 (Macintosh; U; Intel Mac OS X; en-US; rv:1.8.1.11) Gecko/20071127 Firefox/2.0.0.11";

my $travian = Travian->new($server, agent => $USERAGENT);

if (!$travian->login($user, $pass))
{
	croak $travian->error_msg();
}

foreach my $report_header (@{$travian->report_headers()})
{
	print $report_header->id();
	print "\t";
	print $report_header->subject();
	print "\t";
	print $report_header->sent();
	print "\n";
}


