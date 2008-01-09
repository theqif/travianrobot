#!/usr/bin/perl -w

use XML::Simple;
use Data::Dumper;
use Carp;

use lib '../lib';
use Travian qw(calc_traveltime);
use Travian::Troops::Gauls;
use Travian::Troops::Romans;
use Travian::Troops::Teutons;

my $TARGETS_XML = '../data/magicrat_targets.xml';

my $SERVER = 3;
my $USERAGENT = 'Mozilla/5.0 (X11; U; Linux x86_64; en-GB; rv:1.8.1.11) Gecko/20071204 Ubuntu/7.10 (gutsy) Firefox/2.0.0.11';

my $USER = shift;
my $PASS = shift;
my $WAVE = shift;

die "usage: $0 [user] [pass] [wave]\n" unless $USER && $PASS;

my $travian = Travian->new($SERVER, agent => $USERAGENT);
my $raid = &load_xml($travian, $TARGETS_XML);
my $sleeptime;

if (!$WAVE) { $WAVE = 1; }
&init_waves($raid, $WAVE);

while (1)
{
	$sleeptime = 0;

	if (!$travian->login($USER, $PASS))
	{
		croak $travian->error_msg();
	}

	foreach my $village (@{$raid->{'village'}})
	{
		if (!$travian->village($village->{'id'}))
		{
			croak $travian->error_msg();
		}

		my $wave = &get_next_wave($village);

		foreach my $default_target (@{$village->{'default_wave'}->{'target'}})
		{
			if (!$travian->send_troops(Travian::ATTACK_RAID, $default_target->{'x'}, $default_target->{'y'}, $default_target->{'troops'}))
			{
				croak $travian->error_msg();
			}
			my $velocity = &get_velocity($default_target->{'troops'}, $raid->{'troop_attributes'});
			my $traveltime = &calc_traveltime($travian->village()->x(), $travian->village()->y(), $default_target->{'x'}, 
								$default_target->{'y'}, $velocity);
			print &log_msg($village->{'id'}, 'x', $default_target->{'x'}, $default_target->{'y'}, $default_target->{'village'},
					$traveltime*2);
			print "\n";
			$sleeptime = $traveltime if ($traveltime > $sleeptime);
		}

		foreach my $target (@{$wave->{'target'}})
		{
			if (!$travian->send_troops(Travian::ATTACK_RAID, $target->{'x'}, $target->{'y'}, $target->{'troops'}))
			{
				croak $travian->error_msg();
			}
			my $velocity = &get_velocity($target->{'troops'}, $raid->{'troop_attributes'});
			my $traveltime = &calc_traveltime($travian->village()->x(), $travian->village()->y(), $target->{'x'}, $target->{'y'}, $velocity);
			print &log_msg($village->{'id'}, $village->{'wave_index'} + 1, $target->{'x'}, $target->{'y'}, $target->{'village'},
					$traveltime*2);
			print "\n";
			$sleeptime = $traveltime if ($traveltime > $sleeptime);
		}
	}

	sleep int($sleeptime) * 2 + 10;
}

sub init_waves
{
	my ($raid, $wave_index) = @_;

	foreach my $village (@{$raid->{'village'}})
	{
		$village->{'wave_index'} = $wave_index - 2;
	}	
}

sub get_next_wave
{
	my $village = shift;

	if (!defined($village->{'wave_index'}))
	{
		$village->{'wave_index'} = -1;
	}

	if ($#{@{$village->{'wave'}}} < 0) { return; }

	$village->{'wave_index'}++;

	if ($village->{'wave_index'} >= $#{@{$village->{'wave'}}} + 1)
	{
		$village->{'wave_index'} = 0;
	}

	return $village->{'wave'}->[$village->{'wave_index'}];	
}

sub log_msg
{
	my ($village_id, $wave, $x, $y, $village, $traveltime) = @_;

	return '[' . scalar(localtime()) . "] ($village_id) Wave ($wave) - ($x|$y) $village (" . &traveltime($traveltime) . ' mins)';
}

sub traveltime
{
	my $seconds = shift;

	return int($seconds / 60) . ':' . int((($seconds / 60) - int($seconds / 60)) * 60);
}

sub get_velocity
{
	my ($troops, $troop_attributes) = @_;

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

	## Troop Attributes
	$raid->{'troop_type'} = 'Romans' unless ($raid->{'troop_type'});
	$raid->{'troop_attributes'} = &get_troop_attributes($travian, $raid->{'troop_type'});

	## Villages
	croak 'No village found.' unless ($raid->{'village'});
	$raid->{'village'} = [ $raid->{'village'} ] if (ref($raid->{'village'}) eq 'HASH');

	foreach my $village (@{$raid->{'village'}})
	{
		croak 'No village id or coords found.' unless ($village->{'id'} || ($village->{'x'} && $village->{'y'}));
		
		## Default Troops
		if (defined($village->{'default_troops'}))
		{
			$village->{'default_troops'} = &get_troops($village->{'default_troops'}, $raid->{'troop_type'});
		}

		## Default Wave
		if (defined($village->{'default_wave'}))
		{
			## Default Wave Targets
			$village->{'default_wave'}->{'target'} = [ $village->{'default_wave'}->{'target'} ]
				if (ref($village->{'default_wave'}->{'target'}) eq 'HASH');

			$village->{'default_wave'}->{'target'} = &get_targets($village->{'default_wave'}->{'target'}, $raid->{'troop_type'}, 
									$village->{'default_troops'});
		}

		## Waves
		$village->{'wave'} = [ $village->{'wave'} ] if (ref($village->{'wave'}) eq 'HASH');

		foreach my $wave (@{$village->{'wave'}})
		{
			#croak 'Invalid wave id.' unless ($wave->{'id'} && int($wave->{'id'}));

			## Targets
			$wave->{'target'} = [ $wave->{'target'} ] if (ref($wave->{'target'}) eq 'HASH');
			$wave->{'target'} = &get_targets($wave->{'target'}, $raid->{'troop_type'}, $village->{'default_troops'});
		}
	}

	return $raid;
}

sub get_troop_attributes
{
	my ($travian, $troop_type) = @_;
	my $troop_type_id = 0;

	$troop_type_id = Travian::TROOP_TYPE_ROMANS if (uc($troop_type) eq 'ROMANS');
	$troop_type_id = Travian::TROOP_TYPE_GAULS if (uc($troop_type) eq 'GAULS');
	$troop_type_id = Travian::TROOP_TYPE_TEUTONS if (uc($troop_type) eq 'TEUTONS');
	
	croak 'Invalid troop type.' unless ($troop_type_id);

	return $travian->troop_attributes($troop_type_id);
}

sub get_troops
{
	my ($troops_ref, $troop_type) = @_;

	my $troop_class = 'Travian::Troops::' . ucfirst(lc($troop_type));
	my $troops = $troop_class->new();

	foreach my $troop (keys %{$troops_ref})
	{
		$troops->$troop($troops_ref->{$troop});
	}

	return $troops;
}

sub get_targets
{
	my ($targets, $troop_type, $default_troops) = @_;

	foreach my $target (@{$targets})
	{
		croak 'Target coords or village not defined.' unless ($target->{'x'} && $target->{'y'} && $target->{'village'});
		croak 'Troops not defined.' unless ($target->{'troops'} || $default_troops);
				
		if ($target->{'troops'})
		{
			$target->{'troops'} = &get_troops($target->{'troops'}, $troop_type);	
		}
		else
		{
			$target->{'troops'} = $default_troops;
		}
	}

	return $targets;
}

