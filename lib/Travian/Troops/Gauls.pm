package Travian::Troops::Gauls;

use 5.008008;
use strict;
use warnings;

use Carp;

our $VERSION = '0.01';
our $AUTOLOAD;

my %troops_gauls_fields = (
	phalanx => 0,
	swordsman => 0,
	pathfinder => 0,
	theutates_thunder => 0,
	druidrider => 0,
	haeduan => 0,
	battering_ram => 0,
	trebuchet => 0,
	chieftian => 0,
	settler => 0,
);

=head1 NAME

Travian::Troops::Gauls - a package that defines Travian Gallic troops.

=head1 SYNOPSIS

  use Travian::Troops::Gauls;
  my $gauls = Travian::Troops::Gauls->new();
  $gauls->phalanx(10);
  $gauls->swordsman(20);
  $gauls->pathfinder(30);
  $gauls->theutates_thunder(40);
  $gauls->druidrider(50);
  $gauls->haeduan(60);
  $gauls->battering_ram(70);
  $gauls->trebuchet(80);
  $gauls->chieftian(90);
  $gauls->settler(100);

=head1 DESCRIPTION

This package is for the Gallic troops in Travian.

=head1 METHODS

=head2 new()

  use Travian::Troops::Gauls;

  my $gauls = Travian::Troops::Gauls->new(10, 20, 30, 40, 50, 60, 70, 80, 90, 100);

=cut

sub new
{
	my $class = shift;
	my $self = {
		_permitted => \%troops_gauls_fields,
		%troops_gauls_fields,
	};

	bless $self, $class;

	if (@_)
	{
		$self->phalanx(shift);
		$self->swordsman(shift);
		$self->pathfinder(shift);
		$self->theutates_thunder(shift);
		$self->druidrider(shift);
		$self->haeduan(shift);
		$self->battering_ram(shift);
		$self->trebuchet(shift);
		$self->chieftian(shift);
		$self->settler(shift);
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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Adrian Elgar

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut

1;
