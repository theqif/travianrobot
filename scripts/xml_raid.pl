#!/usr/bin/perl -w

use XML::Simple;
use Data::Dumper;
use Carp;

use lib '../lib';
use Travian qw(calc_traveltime);
use Travian::Troops::Gauls;
use Travian::Troops::Romans;
use Travian::Troops::Teutons;

my $TARGETS_XML = '../data/magicrat_targets2.xml';

my $SERVER = 3;
my $USERAGENT = 'Mozilla/5.0 (X11; U; Linux x86_64; en-GB; rv:1.8.1.11) Gecko/20071204 Ubuntu/7.10 (gutsy) Firefox/2.0.0.11';

my $USER = shift;
my $PASS = shift;

die "usage: $0 [user] [pass]\n" unless $USER && $PASS;

my $travian = Travian->new($SERVER, agent => $USERAGENT);
if (!$travian->login($USER, $PASS))
{
	croak $travian->error_msg();
}

my $raid = &load_xml($travian, $TARGETS_XML);

while (1)
{
	if (!$travian->login($USER, $PASS))
	{
		croak $travian->error_msg();
	}

	foreach my $village (@{$raid->{'village'}})
	{
		# this should still work for single village - no village id set in xml.
		if (!$travian->village($village->{'id'}))
		{
			croak $travian->error_msg();
		}

		foreach my $target (@{$village->{'target'}})
		{
			my $current_time = time;

			if (!$target->{'return_time'} || $target->{'return_time'} < $current_time)
			{
				#if (!$travian->send_troops(Travian::ATTACK_RAID, $target->{'x'}, $target->{'y'}, $target->{'troops'}))
				#{
				#	croak $travian->error_msg();
				#}
				my $velocity = &get_velocity($target->{'troops'}, $raid->{'troop_attributes'});
				my $traveltime = &calc_traveltime($travian->village()->x(), $travian->village()->y(), $target->{'x'}, $target->{'y'},
									$velocity);
				$target->{'return_time'} = $current_time + $traveltime*2 + 10;				
				print &log_msg($village->{'id'}, $target->{'x'}, $target->{'y'}, $target->{'village'}, $traveltime*2);
				print "\n";
			}
		}
	}

	&save_xml($raid, $TARGETS_XML);
	sleep 60;
}

sub log_msg
{
	my ($village_id, $x, $y, $village, $traveltime) = @_;

	return '[' . scalar(localtime()) . "] ($village_id) ($x|$y) $village (" . &traveltime($traveltime) . ' mins)';
}

sub traveltime
{
	my $seconds = shift;

	return int($seconds / 60) . ':' . int((($seconds / 60) - int($seconds / 60)) * 60);
}

sub get_velocity
{
	my ($troops, $troop_attributes) = @_;

	## NOTE - this may break when sending hero

	my $velocity = 1000;
	my $index = 0;
	foreach my $troop (@{$troops->as_arrayref()})
	{
		if ($troop > 0)
		{
			if ($troop_attributes->attributes()->[$index])
			{
				if ($troop_attributes->attributes()->[$index]->velocity() < $velocity)
				{
					$velocity = $troop_attributes->attributes()->[$index]->velocity();
				}
			}
		}

		$index++;
	}

	return $velocity;
}

sub load_xml
{
	my ($travian, $xml) = @_;
	
	my $raid = XMLin($xml, KeyAttr => []);
	#print Dumper($raid);
	#print "\n";

	## Original XML
	my $orig_xml = XMLin($xml, KeyAttr => []);
	$raid->{'xml'} = $orig_xml;

	## Troop Attributes
	$raid->{'troop_attributes'} = &get_troop_attributes($travian);

	## Villages
	croak 'No village found.' unless ($raid->{'village'});
	$raid->{'village'} = [ $raid->{'village'} ] if (ref($raid->{'village'}) eq 'HASH');
	$orig_xml->{'village'} = [ $orig_xml->{'village'} ] if (ref($orig_xml->{'village'}) eq 'HASH');

	my $village_index = 0;
	foreach my $village (@{$raid->{'village'}})
	{
		## Targets
		$village->{'target'} = [ $village->{'target'} ] if (ref($village->{'target'}) eq 'HASH');
		my $orig_xml_village = $orig_xml->{'village'}->[$village_index];
		$orig_xml_village->{'target'} = [ $orig_xml_village->{'target'} ] if (ref($orig_xml_village->{'target'}) eq 'HASH');
		$village->{'target'} = &get_targets($village->{'target'}, $travian->player()->tribe());

		$village_index++;
	}

	return $raid;
}

sub save_xml
{
	my ($raid, $xml_file) = @_;

	#print Dumper($raid->{'xml'});
	#print "\n";

	my $orig_xml = $raid->{'xml'};

	my $village_index = 0;
	foreach my $village (@{$raid->{'village'}})
	{
		my $orig_xml_village = $orig_xml->{'village'}->[$village_index];

		my $target_index = 0;
		foreach my $target (@{$village->{'target'}})
		{
			my $orig_xml_target = $orig_xml_village->{'target'}->[$target_index];

			$orig_xml_target->{'return_time'} = $target->{'return_time'};

			$target_index++;
		}

		$village_index++;
	}

	my $xml = XMLout($raid->{'xml'}, RootName => 'raid');

	if (open(XML, ">$xml_file"))
	{
		print XML $xml;

		close(XML);
	}
}

sub get_troop_attributes
{
	my ($travian) = @_;
	my $tribe_type_id = 0;

	$tribe_type_id = Travian::TRIBE_TYPE_ROMANS if (uc($travian->player()->tribe()) eq 'ROMANS');
	$tribe_type_id = Travian::TRIBE_TYPE_GAULS if (uc($travian->player()->tribe()) eq 'GAULS');
	$tribe_type_id = Travian::TRIBE_TYPE_TEUTONS if (uc($travian->player()->tribe()) eq 'TEUTONS');
	
	croak 'Invalid troop type.' unless ($tribe_type_id);

	return $travian->troop_attributes($tribe_type_id);
}

sub get_troops
{
	my ($troops_ref, $tribe_type) = @_;

	my $troop_class = 'Travian::Troops::' . ucfirst(lc($tribe_type));
	my $troops = $troop_class->new();

	foreach my $troop (keys %{$troops_ref})
	{
		$troops->$troop($troops_ref->{$troop});
	}

	return $troops;
}

sub get_targets
{
	my ($targets, $tribe_type) = @_;

	foreach my $target (@{$targets})
	{
		croak 'Target coords or village not defined.' unless ($target->{'x'} && $target->{'y'} && $target->{'village'});
		croak 'Troops not defined.' unless $target->{'troops'};
				
		if ($target->{'troops'})
		{
			$target->{'troops'} = &get_troops($target->{'troops'}, $tribe_type);	
		}
	}

	return $targets;
}

