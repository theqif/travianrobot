package Travian::Troops::Romans;

use 5.008008;
use strict;
use warnings;

use Carp;

our $VERSION = '0.01';
our $AUTOLOAD;

my %troops_roman_fields = (
	legionnaire => 0,
	praetorian => 0,
	imperian => 0,
	equites_legati => 0,
	equites_imperatoris => 0,
	equites_caesaris => 0,
	battering_ram => 0,
	fire_catapult => 0,
	senator => 0,
	settler => 0,
);

=head1 NAME

Travian::Troops::Romans - a package that defines Travian Roman troops.

=head1 SYNOPSIS

  use Travian::Troops::Romans;
  my $romans = Travian::Troops::Romans->new();
  $romans->legionnaire(10);
  $romans->praetorian(20);
  $romans->imperian(30);
  $romans->equites_legati(40);
  $romans->equites_imperatoris(50);
  $romans->equites_caesaris(60);
  $romans->battering_ram(70);
  $romans->fire_catapult(80);
  $romans->senator(90);
  $romans->settler(100);

=head1 DESCRIPTION

This package is for the Roman troops in Travian.

=head1 METHODS

=head2 new()

  use Travian::Troops::Romans;

  my $romans = Travian::Troops::Romans->new(10, 20, 30, 40, 50, 60, 70, 80, 90, 100);

=cut

sub new
{
	my $class = shift;
	my $self = {
		_permitted => \%troops_roman_fields,
		%troops_roman_fields,
	};

	bless $self, $class;

	if (@_)
	{
		$self->legionnaire(shift);
		$self->praetorian(shift);
		$self->imperian(shift);
		$self->equites_legati(shift);
		$self->equites_imperatoris(shift);
		$self->equites_caesaris(shift);
		$self->battering_ram(shift);
		$self->fire_catapult(shift);
		$self->senator(shift);
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
