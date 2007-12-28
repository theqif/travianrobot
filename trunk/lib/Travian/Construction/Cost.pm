package Travian::Construction::Cost;

use strict;
use warnings;

use Carp;
use Travian::Resources;

our $VERSION = '0.01';
our $AUTOLOAD;

my %cost_fields = (
	resources => undef,
	culture_points => 0,
);

=head1 NAME

Travian::Construction::Cost - a package that defines Travian construction costs.

=head1 SYNOPSIS

  use Travian::Construction::Cost;
  my $cost = Travian::Construction::Cost->new();
  $cost->wood(100);
  $cost->clay(200);
  $cost->iron(300);
  $cost->wheat(400);
  $cost->wheat_consumption(50);
  $cost->culture_points(6);

  print $cost->resources()->wood();

=head1 DESCRIPTION

This package is for a single level of construction costs in Travian.

=head1 METHODS

=head2 new()

  use Travian::Construction::Cost;

  my $cost = Travian::Construction::Cost->new(100, 200, 300, 400, 50, 6);

=cut

sub new
{
	my $class = shift;
	my $self = {
		_permitted => \%cost_fields,
		%cost_fields,
	};

	bless $self, $class;

	if (@_)
	{
		$self->{'resources'} = Travian::Resources->new(shift, shift, shift, shift, shift);
		$self->culture_points(shift);
	}
	else
	{
		$self->{'resources'} = Travian::Resources->new();
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

	
	if (exists $self->{_permitted}->{$name}) 
	{
		if (@_)
		{
			return $self->{$name} = shift;
		}
		else
		{
			return $self->{$name};
		}
	}
	elsif (ref($self->{'resources'}) eq 'Travian::Resources' && exists($self->{'resources'}->{$name}))
	{
		if (@_)
		{
			return $self->{'resources'}->{$name} = shift;
		}
		else
		{
			return $self->{'resources'}->{$name};
		}
	}
	else
	{
		croak "Can't access `$name' field in class $type";
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
