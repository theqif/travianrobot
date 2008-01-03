package Travian::Building;

use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);
our @EXPORT_OK = qw(&gid2name &name2gid &time2secs);

use Carp;
use Travian::Building::Cost;

our $VERSION = '0.01';
our $AUTOLOAD;

our @GID2NAME = (
	'Building site', 'Woodcutter', 'Clay Pit', 'Iron Mine', 'Cropland',
	'Sawmill', 'Brickyard', 'Iron Foundry', 'Grain Mill',
	'Bakery', 'Warehouse', 'Granary', 'Blacksmith',
	'Armoury', 'Tournament Square', 'Main Building', 'Rally Point',
	'Marketplace', 'Embassy', 'Barracks', 'Stable',
	'Workshop', 'Academy', 'Cranny', 'Town Hall',
	'Residence', 'Palace', 'Treasury', 'Trade Office',
	'Great Barracks', 'Great Stable', 'City Wall', 'Earth Wall',
	'Palisade', 'Stonemason', 'Brewery', 'Trapper',
	'Hero\'s Mansion', 'Great Warehouse', 'Great Granary', 'Wonder of the World'
);

our %NAME2GID = (
	'Building site' => 0, 'Woodcutter' => 1, 'Clay Pit' => 2, 'Iron Mine' => 3, 'Cropland' => 4, 'Wheat Field' => 4,
	'Sawmill' => 5, 'Brickyard' => 6, 'Iron Foundry' => 7, 'Grain Mill' => 8,
	'Bakery' => 9, 'Warehouse' => 10, 'Granary' => 11, 'Blacksmith' => 12,
	'Armoury' => 13, 'Tournament Square' => 14, 'Main Building' => 15, 'Rally Point' => 16,
	'Marketplace' => 17, 'Embassy' => 18, 'Barracks' => 19, 'Stable' => 20,
	'Workshop' => 21, 'Academy' => 22, 'Cranny' => 23, 'Town Hall' => 24,
	'Residence' => 25, 'Palace' => 26, 'Treasury' => 27, 'Trade Office' => 28,
	'Great Barracks' => 29, 'Great Stable' => 30, 'City Wall' => 31, 'Earth Wall' => 32,
	'Palisade' => 33, 'Stonemason' => 34, 'Brewery' => 35, 'Trapper' => 36,
	'Hero\'s Mansion' => 37, 'Great Warehouse' => 38, 'Great Granary' => 39, 'Wonder of the World' => 40,
);

my %building_fields = (
	gid => 0,
	level => 0,
);

=head1 NAME

Travian::Building - a package that defines a Travian building.

=head1 SYNOPSIS

  use Travian::Building;
  my $building = Travian::Building->new(35);
  print $building->gid();
  print $building->name();
  print $building->level();

  print $building->costs($level)->wood();
  foreach my $cost (@{$building->costs()})
  {
    print $cost->wood();
  }

  print $building->times($level, $mb_level);

=head1 DESCRIPTION

This package is for a single building in Travian.

=head1 METHODS

=head2 new()

  use Travian::Building;

  my $building = Travian::Building->new($gid);

=cut

sub new
{
	my $class = shift;
	my $self = {
		_permitted => \%building_fields,
		%building_fields,
	};

	bless $self, $class;

	if (@_)
	{
		$self->gid(shift);
	}
	
	$self->{'costs'} = [];
	$self->{'times'} = [];

	return $self;
}

=head2 gid()

  $building->gid();

Returns the gid of this building.

=head2 name()

  $building->name();

Returns the name of this building.

=cut

sub name
{
	my $self = shift;

	return &gid2name($self->gid());
}

=head2 costs()

  $building->costs();
  $building->costs($level);

Returns the building costs for the given level.
Return value is of type Travian::Building::Cost.
If no argument is given returns an array ref for all levels of build.

=cut

sub costs
{
	my $self = shift;

	if (@_)
	{
		my $level = shift;

		if ($level > 0 && $level <= $self->max_lvl())
		{
			return $self->{'costs'}->[$level - 1];
		}

		return;
	}

	return $self->{'costs'};
}

=head2 times()

  $building->times();
  $building->times($level);
  $building->times($level, $mb_level);

Returns the build time for the given level and main building level.
If no main building level is given returns an array ref of build times for $level.
If no argument is given returns an array ref for all levels of build.

=cut

sub times
{
	my $self = shift;

	if (@_)
	{
		my $level = shift;

		if ($level > 0 && $level <= $#{$self->{'times'}} + 1)
		{
			if (@_)
			{
				my $mb_level = shift;
				
				if ($mb_level > 0 && $mb_level <= $#{$self->{'times'}->[$level - 1]} + 1)
				{
					return $self->{'times'}->[$level - 1]->[$mb_level - 1];
				}

				return;
			}

			return $self->{'times'}->[$level - 1];
		}

		return;
	}

	return $self->{'times'};
}

=head2 max_lvl()

  $building->max_lvl();

Returns the maximum build level listed for this building.

=cut

sub max_lvl
{
	my $self = shift;

	return $#{$self->{'costs'}} + 1;
}

=head2 total_cost()

  $building->total_cost();
  $building->total_cost(25);
  $building->total_cost(1, 25);

Returns the total build costs for the given build levels.
The above examples are all interchangeable.

=cut

sub total_cost
{
	my $self = shift;
	my $min_lvl = shift;
	my $max_lvl = shift;

	if ($min_lvl)
	{
		$min_lvl = 1 unless $min_lvl > 0;
		$min_lvl = $self->max_lvl() unless $min_lvl <= $self->max_lvl();

		if ($max_lvl)
		{
			$max_lvl = 1 unless $max_lvl > 0;
			$max_lvl = $self->max_lvl() unless $max_lvl <= $self->max_lvl();

			if ($min_lvl > $max_lvl)
			{
				return $self->total_cost($max_lvl, $min_lvl);
			}

			my $total_cost = Travian::Building::Cost->new();
			for (my $lvl = $min_lvl; $lvl <= $max_lvl; $lvl++)
			{
				my $cost = $self->costs($lvl);
				$total_cost->wood($total_cost->wood() + $cost->wood());
				$total_cost->clay($total_cost->clay() + $cost->clay());
				$total_cost->iron($total_cost->iron() + $cost->iron());
				$total_cost->wheat($total_cost->wheat() + $cost->wheat());
				$total_cost->wheat_consumption($total_cost->wheat_consumption() + $cost->wheat_consumption());
				$total_cost->culture_points($total_cost->culture_points() + $cost->culture_points());
			}

			return $total_cost;
		}

		return $self->total_cost(1, $min_lvl);
	}

	return $self->total_cost(1, $self->max_lvl());
}

=head2 parse_construction()

  $building->parse_construction($construction_html);
  
Parses the given construction html and populates this building with costs and times.
Returns this building.

=cut

sub parse_construction
{
	my $self = shift;

	if (@_)
	{
		my $construction_html = shift;
		chomp($construction_html);

		my $construction_tables = [ $construction_html =~ m#<table.*?>(.+?)</table>#mgs ];

		foreach my $construction_table (@{$construction_tables})
		{
			$construction_table =~ s/\s//g;
			$self->{'costs'} = &parse_construction_costs($construction_table) if ($construction_table =~ /CP/);
			$self->{'times'} = &parse_construction_times($construction_table) if ($construction_table =~ /MB1</);
			if ($construction_table =~ /MB11/)
			{
				my $construction_times = &parse_construction_times($construction_table);
				for (my $index = 0; $index <= $#{$construction_times}; $index++)
				{
					push(@{$self->{'times'}->[$index]}, @{$construction_times->[$index]});
				}
			}
		}

		return $self;
	}

	return;
}

=head1 PARSE FUNCTIONS

=head2 parse_construction_costs()

  &parse_construction_costs($construction_costs_html);
  
Parses the given construction costs html and returns an array ref of costs.
Used by $building->parse_construction().

=cut

sub parse_construction_costs
{
	my $costs_table_html = shift;
	my $costs = [];

	my $costs_rows = [ $costs_table_html =~ m#<tr>(.+?)</tr>#mgs ];
	foreach my $costs_row (@{$costs_rows})
	{
		my $cost = [ $costs_row =~ m#<td>(.+?)</td>#mgs ];
		next if (!$cost->[0] || $cost->[0] !~ /^\d+$/o);

		push @{$costs}, Travian::Building::Cost->new($cost->[1], $cost->[2], $cost->[3], $cost->[4], $cost->[5], $cost->[6]);
	}

	return $costs;
}

=head2 parse_construction_times()

  &parse_construction_times($construction_times_html);
  
Parses the given construction times html and returns an array ref of times.
Used by $building->parse_construction().

=cut

sub parse_construction_times
{
	my $times_table_html = shift;
	my $times = [];

	my $times_rows = [ $times_table_html =~ m#<tr>(.+?)</tr>#msg ];
	foreach my $times_row (@{$times_rows})
	{
		my $time = [ $times_row =~ m#<td>(.+?)</td>#mgs ];
		next if (!$time->[0] || $time->[0] !~ /^\d+$/o);
		
		shift(@{$time});
		@{$time} = map(&time2secs($_), @{$time});

		push @{$times}, $time;
	}

	return $times;
}

=head1 FUNCTIONS

=head2 gid2name()

  &gid2name($gid);
  
Returns the building's name for the given gid.

=cut

sub gid2name
{
	my $gid = shift;

	if ($gid =~ /\d+/ && $gid >= 0 && $gid <= 41)
	{
		return $GID2NAME[$gid];
	}

	return;
}

=head2 name2gid()

  &name2gid($name);
  
Returns the building's gid for the given name.

=cut

sub name2gid
{
	my $name = shift;

	if ($name && $NAME2GID{$name})
	{
		return $NAME2GID{$name};
	}

	return;
}

=head2 time2secs()

  &time2secs($time);
  
Given a time in format h:m:s returns number of seconds.

=cut

sub time2secs
{
	my $time = shift;

	#print $time;
	#print "\n";

	$time =~ /(\d+?):(\d+?):(\d+?)/;
	my $hours = $1;
	my $mins = $2;
	my $secs = $3;

	return (($hours * 60) + $mins) * 60 + $secs;
}

sub AUTOLOAD
{
	my $self = shift;
	my $type = ref($self)
		or croak "$self is not an object";

	my $name = $AUTOLOAD;
	$name =~ s/.*://;   # strip fully-qualified portion

	unless (exists $self->{_permitted}->{$name}) 
	{
		croak "Can't access `$name' field in class $type";
	}

	if (@_)
	{
		return $self->{$name} = shift;
	}
	else
	{
		return $self->{$name};
	}
}

sub DESTROY { }

=head1 AUTHOR

Adrian D. Elgar, E<lt>ade@wasters.comE<gt>
Martin Robertson, E<lt>marley@wasters.comE<gt>

=head1 SEE ALSO

Travian::Building::Cost

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Adrian Elgar, Martin Robertson

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut

1;
