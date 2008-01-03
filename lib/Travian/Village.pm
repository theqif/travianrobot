package Travian::Village;

use strict;
use warnings;

use Carp;
use Travian::Resources;
use Travian::Building qw(gid2name name2gid);

our $VERSION = '0.01';
our $AUTOLOAD;

my %village_fields = (
	village_name => '',
	village_id => 0,
	x => 0,
	y => 0,
	current_resources => undef,
	max_resources => undef,
	production_resources => undef,
	buildings => undef,
);

=head1 NAME

Travian::Village - a package that defines a Travian village.

=head1 SYNOPSIS

  use Travian::Village;
  my $village = Travian::Village->new('My Village');
  $village->village_name();
  $village->village_id();
  $village->x();
  $village->y();

  $village->current_resources();
  $village->max_resources();
  $village->production_resources();

  foreach my $building (@{$village->buildings()})
  {
	print $building->name();
  }
  $village->buildings($building_id);

=head1 DESCRIPTION

This package is for a single village in Travian.

=head1 METHODS

=head2 new()

  use Travian::Village;

  my $village = Travian::Village->new('My Village');

=cut

sub new
{
	my $class = shift;
	my $self = {
		_permitted => \%village_fields,
		%village_fields,
	};

	bless $self, $class;

	if (@_)
	{
		$self->village_name(shift);
		$self->village_id(shift);
	}

	$self->{'current_resources'} = Travian::Resources->new();
	$self->{'max_resources'} = Travian::Resources->new();
	$self->{'production_resources'} = Travian::Resources->new();

	$self->{'buildings'} = [];
	for (my $building_id = 1; $building_id <= 40; $building_id++)
	{
		push(@{$self->{'buildings'}}, Travian::Building->new());
	}

	return $self;
}

=head2 current_resources()

  $village->current_resources();
  $village->current_wood();
  $village->current_clay();
  $village->current_iron();
  $village->current_wheat();
  $village->current_wheat_consumption();

Returns the current resources.

=cut

sub current_wood { return $_[0]->current_resources()->wood(); }
sub current_clay { return $_[0]->current_resources()->clay(); }
sub current_iron { return $_[0]->current_resources()->iron(); }
sub current_wheat { return $_[0]->current_resources()->wheat(); }
sub current_wheat_consumption { return $_[0]->current_resources()->wheat_consumption(); }

=head2 max_resources()

  $village->max_resources();
  $village->max_wood();
  $village->max_clay();
  $village->max_iron();
  $village->max_wheat();
  $village->max_wheat_consumption();

Returns the maximum values of resources.

=cut

sub max_wood { return $_[0]->max_resources()->wood(); }
sub max_clay { return $_[0]->max_resources()->clay(); }
sub max_iron { return $_[0]->max_resources()->iron(); }
sub max_wheat { return $_[0]->max_resources()->wheat(); }
sub max_wheat_consumption { return $_[0]->max_resources()->wheat_consumption(); }

=head2 production_resources()

  $village->production_resources();
  $village->production_wood();
  $village->production_clay();
  $village->production_iron();
  $village->production_wheat();

Returns the production rate of resources.

=cut

sub production_wood { return $_[0]->production_resources()->wood(); }
sub production_clay { return $_[0]->production_resources()->clay(); }
sub production_iron { return $_[0]->production_resources()->iron(); }
sub production_wheat { return $_[0]->production_resources()->wheat(); }

=head2 buildings()

  $village->buildings();
  $village->buildings($building_id);

Returns the building for the given id.
Return value is of type Travian::Building.
If no argument is given returns an array ref of all buildings.

=cut

sub buildings
{
	my $self = shift;

	if (@_)
	{
		my $building_id = shift;

		if ($building_id > 0 && $building_id <= 40)
		{
			return $self->{'buildings'}->[$building_id - 1];
		}

		return;
	}

	return $self->{'buildings'};
}

=head2 parse_village_overview()

  $village->parse_village_overview($village_overview_html);

Parse the village overview html and populate this village.

=cut

sub parse_village_overview
{
	my $self = shift;
	my $village_overview_html = shift;

	if ($village_overview_html && $village_overview_html =~ /logout.php/msg)
	{
		## Village Name
		if ($village_overview_html =~ m#div class="dname"><h1>(.+?)</h1>#msg)
		{
			my $village_name = $1;
			$self->village_name($village_name);
		}

		## Resources
		if ($village_overview_html =~ m#<td id=l4 title=(\d+?)>(\d+?)/(\d+?)</td>#msg)
		{
			my $production = $1; my $current = $2; my $max = $3;
			$self->production_resources()->wood($production);
			$self->current_resources()->wood($current);
			$self->max_resources()->wood($max);
		}
		if ($village_overview_html =~ m#<td id=l3 title=(\d+?)>(\d+?)/(\d+?)</td>#msg)
		{
			my $production = $1; my $current = $2; my $max = $3;
			$self->production_resources()->clay($production);
			$self->current_resources()->clay($current);
			$self->max_resources()->clay($max);
		}
		if ($village_overview_html =~ m#<td id=l2 title=(\d+?)>(\d+?)/(\d+?)</td>#msg)
		{
			my $production = $1; my $current = $2; my $max = $3;
			$self->production_resources()->iron($production);
			$self->current_resources()->iron($current);
			$self->max_resources()->iron($max);
		}
		if ($village_overview_html =~ m#<td id=l1 title=(\d+?)>(\d+?)/(\d+?)</td>#msg)
		{
			my $production = $1; my $current = $2; my $max = $3;
			$self->production_resources()->wheat($production);
			$self->current_resources()->wheat($current);
			$self->max_resources()->wheat($max);
		}
		if ($village_overview_html =~ m#title="Wheat consumption">&nbsp;(\d+?)/(\d+?)</td>#msg)
		{
			my $current = $1; my $max = $2;
			$self->current_resources()->wheat_consumption($current);
			$self->max_resources()->wheat_consumption($max);
		}

		## Buildings
		return $self->parse_buildings($village_overview_html);
	}

	return;
}

=head2 parse_village_centre()

  $village->parse_village_centre($village_centre_html);

Parse the village centre html and populate this village.

=cut

sub parse_village_centre
{
	my $self = shift;
	my $village_centre_html = shift;

	if ($village_centre_html && $village_centre_html =~ /logout.php/msg)
	{
		## Buildings
		return $self->parse_buildings($village_centre_html);
	}

	return;
}

=head2 parse_buildings()

  $village->parse_buildings($village_buildings_html);

Parse the buildings from either village overview or village centre and populate this village.

=cut

sub parse_buildings
{
	my $self = shift;
	my $village_buildings_html = shift;

	my $buildings = [ $village_buildings_html =~ m#<area (.+?)>#mgs ];
	foreach (@{$buildings})
	{
		next unless (/build.php\?id=(\d+?)"/);
		my $building_id = $1;
		if (/title="(.+?) level (\d+?)"/)
		{
			my $name = $1; my $level = $2;

			my $building = Travian::Building->new();
			$building->gid(&name2gid($name));			
			$building->level($level);
			@{$self->{'buildings'}}[$building_id - 1] = $building;
		}
	}

	return $self;
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

Travian::Resources

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Adrian Elgar, Martin Robertson

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut

1;
