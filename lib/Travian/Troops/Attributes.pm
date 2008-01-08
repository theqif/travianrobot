package Travian::Troops::Attributes;

use strict;
use warnings;

use Carp;

use Travian::Resources;

our $VERSION = '0.01';
our $AUTOLOAD;

my %attribute_fields = (
	attack => 0,
	defence_infantry => 0,
	defence_cavalry => 0,
	cost => undef,
	velocity => 0,
);

=head1 NAME

Travian::Troops::Attributes - a package that defines attributes for Travian troops.

=head1 SYNOPSIS

  use Travian::Troops::Attributes;
  my $attributes = Travian::Troops::Attributes->new(15, 40, 50, 100, 130, 55, 30, 1, 7);

  $attributes->attack();
  $attributes->defence_infantry();
  $attributes->defence_cavalry();
  $attributes->cost()->wood();
  $attributes->velocity();

=head1 DESCRIPTION

This package is for the troop attributes in Travian.

=head1 METHODS

=head2 new()

  use Travian::Troops::Attributes;

  my $attributes = Travian::Troops::Attributes->new(15, 40, 50, 100, 130, 55, 30, 1, 7);

=cut

sub new
{
	my $class = shift;
	my $self = {
		_permitted => \%attribute_fields,
		%attribute_fields,
	};

	bless $self, $class;

	$self->{'cost'} = Travian::Resources->new();

	if (@_)
	{
		$self->attack(shift);
		$self->defence_cavalry(shift);
		$self->defence_infantry(shift);
		$self->{'cost'} = Travian::Resource->new(shift, shift, shift, shift, shift);
		$self->velocity(shift);
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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Adrian Elgar, Martin Robertson

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut

1;
