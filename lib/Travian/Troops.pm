package Travian::Troops;

use strict;
use warnings;

use Carp;

our $VERSION = '0.01';

=head1 NAME

Travian::Troops - a package that defines Travian troops.

=head1 SYNOPSIS

  use Travian::Troops;
  my $troops = Travian::Troops->new(10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 1);
  
  $troops->send_troops_args();

=head1 DESCRIPTION

This package is for the troops in Travian.

=head1 METHODS

=head2 new()

  use Travian::Troops;

  my $troops = Travian::Troops->new(10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 1);

=cut

sub new
{
	my $class = shift;
	my $self = { };

	bless $self, $class;

	$self->{'_troops'} = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

	if (@_)
	{
		$self->{'_troops'}->[0] = shift || 0;
		$self->{'_troops'}->[1] = shift || 0;
		$self->{'_troops'}->[2] = shift || 0;
		$self->{'_troops'}->[3] = shift || 0;
		$self->{'_troops'}->[4] = shift || 0;
		$self->{'_troops'}->[5] = shift || 0;
		$self->{'_troops'}->[6] = shift || 0;
		$self->{'_troops'}->[7] = shift || 0;
		$self->{'_troops'}->[8] = shift || 0;
		$self->{'_troops'}->[9] = shift || 0;
		$self->{'_troops'}->[10] = shift || 0;
	}

	return $self;
}

=head2 as_arrayref()

  $troops->as_arrayref();

Returns an array ref of the troops.

=cut

sub as_arrayref
{
	return $_[0]->{'_troops'};
}

=head2 send_troops_args()

  $troops->send_troops_args();

Returns an array ref of the troops for passing to send troops forms.

=cut

sub send_troops_args
{
	my $self = shift;

	my $send_troops_args = [];

	for (my $troop_index = 0; $troop_index < 11; $troop_index++)
	{
		push @{$send_troops_args}, 't' . ($troop_index + 1) => $self->{'_troops'}->[$troop_index];
	}

	return $send_troops_args;
}

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
