package Travian::Report::Unit;

use strict;
use warnings;

our $VERSION = '0.01';
our $AUTOLOAD;

use Carp;
use Travian::Troops;
use Travian::Troops::Gauls;
use Travian::Troops::Romans;
use Travian::Resources;

my %unit_fields = (
	name => '',
	village => '',
	troops => undef,
	casualties => undef,
	prisoners => undef,
	resources => undef,
	info => '',
);

=head1 NAME

Travian::Report::Unit - a package that defines a Travian report's units.

=head1 SYNOPSIS

  use Travian::Report::Unit;
  my $unit = Travian::Report::Unit->new('magicrat', 'magicrat Village');
  print $unit->name();
  print $unit->village();

  $unit->troops();
  $unit->casualties();
  $unit->prisoners();
  
  $unit->bounty();
  $unit->resources();

  print $unit->info();

=head1 DESCRIPTION

This package is for a single report unit in Travian.

=head1 METHODS

=head2 new()

  use Travian::Report::Unit;

  my $unit = Travian::Report::Unit->new();

=cut

sub new
{
	my $class = shift;
	my $self = {
		_permitted => \%unit_fields,
		%unit_fields,
	};

	bless $self, $class;

	$self->{'troops'} = Travian::Troops->new();
	$self->{'casualties'} = Travian::Troops->new();
	$self->{'prisoners'} = Travian::Troops->new();	
	$self->{'resources'} = Travian::Resources->new();
	
	if (@_)
	{
		$self->name(shift);
		$self->village(shift);
	}

	return $self;
}

sub bounty { $_[0]->resources(); }

=head2 parse_unit()

  $unit->parse_construction($unit_html);
  
Parses the given unit html and populates this unit.
Returns this unit.

=cut

sub parse_unit
{
	my $self = shift;
	my $unit_html = shift;

	if ($unit_html)
	{
		$unit_html =~ s#<tr.*?>#<tr>#g;

		my $troop_type = 'Travian::Troops';

		my $unit_rows = [ $unit_html =~ m#<tr>(.+?)</tr>#msg ];
		foreach my $unit_row (@{$unit_rows})
		{
			$unit_row =~ s#<td.*?>#<td>#g;

			my $unit_row_tds = [ $unit_row =~ m#<td>(.+?)</td>#msg ];
			
			$self->parse_unit_header($unit_row_tds->[1]) if ($unit_row_tds->[0] eq 'Attacker');
			$self->parse_unit_header($unit_row_tds->[1]) if ($unit_row_tds->[0] eq 'Defender');
			
			if ($unit_row_tds->[0] eq '&nbsp;')
			{
				$troop_type = 'Travian::Troops::Gauls' if ($unit_row_tds->[1] =~ /Phalanx/);
				$troop_type = 'Travian::Troops::Romans' if ($unit_row_tds->[1] =~ /Legionnaire/);

				$self->{'troops'} = $troop_type->new();
				$self->{'casualties'} = $troop_type->new();
				$self->{'prisoners'} = $troop_type->new();
			}

			if ($unit_row_tds->[0] eq 'Troops')
			{
				shift(@{$unit_row_tds});
				$self->{'troops'} = $troop_type->new(@{$unit_row_tds});
			}

			if ($unit_row_tds->[0] eq 'Casualties')
			{
				shift(@{$unit_row_tds});
				$self->{'casualties'} = $troop_type->new(@{$unit_row_tds});
			}

			if ($unit_row_tds->[0] eq 'Prisoners')
			{
				shift(@{$unit_row_tds});
				$self->{'prisoners'} = $troop_type->new(@{$unit_row_tds});
			}

			if ($unit_row_tds->[0] eq 'Resources' || $unit_row_tds->[0] eq 'Bounty')
			{
				$self->parse_unit_resources($unit_row_tds->[1]);
			}

			if ($unit_row_tds->[0] eq 'Info')
			{
				$self->{'info'} = $unit_row_tds->[1];
			}
		}

		return $self;
	}

	return;
}

=head2 parse_unit_header()

  $unit->parse_unit_header($unit_header_html);
  
Parses the given unit header html and populates this unit.
Returns this unit.
Called by $unit->parse_unit().

=cut

sub parse_unit_header
{
	my $self = shift;
	my $header_html = shift;

	if ($header_html)
	{
		$header_html =~ m#href="spieler.php.+?>(.+?)</a>#msg;
		my $name = $1;
		$header_html =~ m#href="karte.php.+?>(.+?)</a>#msg;
		my $village = $1;

		$self->{'name'} = $name unless !$name;
		$self->{'village'} = $village unless !$village;

		return $self;
	}

	return;
}

=head2 parse_unit_resources()

  $unit->parse_unit_resources($unit_resources_html);
  
Parses the given unit resources html and populates this unit.
Returns this unit.
Called by $unit->parse_unit().

=cut

sub parse_unit_resources
{
	my $self = shift;
	my $resources_html = shift;

	if ($resources_html)
	{
		my $resources = [ $resources_html =~ m#<img.+?>(\d+)#msg ];

		return $self->{'resources'} = Travian::Resources->new(@{$resources});
	}
	
	return;
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

Travian::Report

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Adrian Elgar, Martin Robertson

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut

1;
