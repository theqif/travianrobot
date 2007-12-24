package Travian::Resources;

use 5.008008;
use strict;
use warnings;

use Carp;

our $VERSION = '0.01';
our $AUTOLOAD;

my %resource_fields = (
	wood => 0,
	clay => 0,
	iron => 0,
	wheat => 0,
	wheat_consumption => 0,
);

=head1 NAME

Travian::Resources - a package that defines Travian resources.

=head1 SYNOPSIS

  use Travian::Resources;
  my $resources = Travian::Resources->new();
  $resources->wood(100);
  $resources->clay(200);
  $resources->iron(300);
  $resources->wheat(400);
  $resources->wheat_consumption(50);

=head1 DESCRIPTION

This package is for the resources in Travian.

=head1 METHODS

=head2 new()

  use Travian::Resources;

  my $resources = Travian::Resources->new(100, 200, 300, 400, 50);

=cut

sub new
{
	my $class = shift;
	my $self = {
		_permitted => \%resource_fields,
		%resource_fields,
	};

	bless $self, $class;

	if (@_)
	{
		$self->wood(shift);
		$self->clay(shift);
		$self->iron(shift);
		$self->wheat(shift);
		$self->wheat_consumption(shift);
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
