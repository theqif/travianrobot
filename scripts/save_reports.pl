#!/usr/bin/perl -w

use lib '../lib/';
use Data::Dumper;
use Travian;
use Carp;

my $server = shift;
my $user = shift;
my $pass = shift;

die "usage: $0 [server] [user] [pass]\n" unless $server && $user && $pass;

#my $USERAGENT = 'Mozilla/5.0 (X11; U; Linux x86_64; en-GB; rv:1.8.1.11) Gecko/20071204 Ubuntu/7.10 (gutsy) Firefox/2.0.0.11';
my $USERAGENT = "Mozilla/5.0 (Macintosh; U; Intel Mac OS X; en-US; rv:1.8.1.11) Gecko/20071127 Firefox/2.0.0.11";

my $t = Travian->new($server, agent => $USERAGENT);

croak $t->error_msg() unless ($t->login($user, $pass));

print "Working with the following IDS :\n";
my $rid_ar = $t->get_report_ids;

print Dumper ($rid_ar);

my $del_ar = [];

foreach my $rid (@{$rid_ar})
{
  my $rep = $t->report($rid);
  croak "Cannot retrieve report $rid." unless ($rep);

  #print $rep->header->subject . "\n";

  if ($rep->header->subject =~ /attacks/o) { if (&save_attack($rep)) { push @{$del_ar}, $rid; } next; }
  if ($rep->header->subject =~ /scouts/o)  { if (&save_scout ($rep)) { push @{$del_ar}, $rid; } next; }
  if ($rep->header->subject =~ /suppli/o)  { if (&save_suppl ($rep)) { push @{$del_ar}, $rid; } next; }

  print "OK?\n";

  #print Dumper ($rep);

}

print "\nDeleting : " . Dumper ($del_ar); $t->delete_reports($del_ar);

sub save_scout
{
  my $r = shift || return 0;
#print Dumper ($r); return 0;

  return 0 unless  ($r->attacker->name =~ /theqif/o);

  my $dt  = $r->header->sent;
     $dt  =~ s/on //msgi;
     $dt  =~ s/ o'clock//msgi;
  my $pfs = $r->attacker->troops    ->{_troops}->[2];
  my $cas = $r->attacker->casualties->{_troops}->[2];

  my $bounty   = join "/", map { $r->attacker->resources->$_()} (qw/wood clay iron wheat/);

  #my $max = ($bounty > ($capacity-75)) ? 1 : 0;
  my $target =  $r->defender->name ." (" . $r->defender->village . ")";

  open (IN, ">>/Users/qif/travian/travianrobot/reports/MR_s3_scouts.txt") || return 0;
  print IN "$dt : [$pfs]/[$cas] : [$bounty] : [$target]\n";
  close IN;

  return 0;
}

sub save_suppl { return 0; } #print shift()->header->subject; }
sub save_attack
{
  my $r = shift || return 0;

  croak "I got attacked!" unless ($r->attacker->name =~ /theqif/o);

  my $dt  = $r->header->sent;
     $dt  =~ s/on //msgi;
     $dt  =~ s/ o'clock//msgi;
  my $tts = $r->attacker->troops    ->{_troops}->[3];
  my $cas = $r->attacker->casualties->{_troops}->[3];

  my $capacity = $tts * 75;
  my $bounty   = 0; foreach (qw/wood clay iron wheat/) { $bounty += $r->attacker->resources->$_(); }

  my $max = ($bounty > ($capacity-75)) ? 1 : 0;
  my $target =  $r->defender->name ." (" . $r->defender->village . ")"; 

  open (IN, ">>/Users/qif/travian/travianrobot/reports/MR_s3_attacks.txt") || return 0;
  print IN "$dt : [$tts] : [$bounty]/[$capacity] : [$cas] : [$max] : [$target]\n";
  close IN;

  return 1;
}

#print "Subject: " . $report->header()->subject() . "\n";
#print "Sent: "    . $report->header()->sent()    . "\n\n";
#
#print "Attacker:\t"; print $report->attacker()->name(); print " ("; print $report->attacker()->village(); print ")\n";
#print "Troops:\t\t"; print join ' ', @{$report->attacker()->troops()->as_arrayref()}; print "\n";
#print "Casualties:\t"; print join ' ', @{$report->attacker()->casualties()->as_arrayref()}; print "\n";
#print "Prisoners:\t"; print join ' ', @{$report->attacker()->prisoners()->as_arrayref()}; print "\n";
#print "Bounty:\t\t"; print $report->attacker()->resources()->wood(); print ' '; print $report->attacker()->resources()->clay(); print ' '; print $report->attacker()->resources()->iron(); print ' '; print $report->attacker()->resources()->wheat(); print "\n";
#print "Info\t\t"; print $report->attacker()->info(); print "\n\n";
#	
#print "Defender:\t"; print $report->defender()->name(); print " ("; print $report->defender()->village(); print ")\n";
#print "Troops:\t\t"; print join ' ', @{$report->defender()->troops()->as_arrayref()}; print "\n";
#print "Casualties:\t"; print join ' ', @{$report->defender()->casualties()->as_arrayref()}; print "\n";
#print "Prisoners:\t"; print join ' ', @{$report->defender()->prisoners()->as_arrayref()}; print "\n";
