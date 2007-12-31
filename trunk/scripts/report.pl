#!/usr/bin/perl -w

use lib '../lib/';
use Travian;
use Carp;

my $server = shift;
my $user = shift;
my $pass = shift;
my $report_id = shift;

die "usage: $0 [server] [user] [pass] [report_id]\n" unless $server && $user && $pass && $report_id;

my $USERAGENT = 'Mozilla/5.0 (X11; U; Linux x86_64; en-GB; rv:1.8.1.11) Gecko/20071204 Ubuntu/7.10 (gutsy) Firefox/2.0.0.11';
#my $USERAGENT = "Mozilla/5.0 (Macintosh; U; Intel Mac OS X; en-US; rv:1.8.1.11) Gecko/20071127 Firefox/2.0.0.11";

my $travian = Travian->new($server, agent => $USERAGENT);

if (!$travian->login($user, $pass))
{
	croak $travian->error_msg();
}

my $report = $travian->report($report_id);
if (!$report)
{
	croak "Cannot retrieve report $report_id.";
}

print "Subject: ";
print $report->header()->subject();
print "\n";
print "Sent: ";
print $report->header()->sent();
print "\n\n";

print "Attacker:\t";
print $report->attacker()->name();
print " (";
print $report->attacker()->village();
print ")\n";
print "Troops:\t\t";
print join ' ', @{$report->attacker()->troops()->as_arrayref()};
print "\n";
print "Casualties:\t";
print join ' ', @{$report->attacker()->casualties()->as_arrayref()};
print "\n";
print "Prisoners:\t";
print join ' ', @{$report->attacker()->prisoners()->as_arrayref()};
print "\n";
print "Bounty:\t\t";
print $report->attacker()->resources()->wood();
print ' ';
print $report->attacker()->resources()->clay();
print ' ';
print $report->attacker()->resources()->iron();
print ' ';
print $report->attacker()->resources()->wheat();
print "\n";
print "Info\t\t";
print $report->attacker()->info();
print "\n\n";
	
print "Defender:\t";
print $report->defender()->name();
print " (";
print $report->defender()->village();
print ")\n";
print "Troops:\t\t";
print join ' ', @{$report->defender()->troops()->as_arrayref()};
print "\n";
print "Casualties:\t";
print join ' ', @{$report->defender()->casualties()->as_arrayref()};
print "\n";
print "Prisoners:\t";
print join ' ', @{$report->defender()->prisoners()->as_arrayref()};
print "\n";
	

