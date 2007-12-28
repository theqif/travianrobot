package Travian::Troops::Gauls;

use 5.008008;
use strict;
use warnings;

use Carp;
use Travian::Troops;

our @ISA = qw(Travian::Troops);

our $VERSION = '0.01';

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
  $gauls->hero(1);

=head1 DESCRIPTION

This package is for the Gallic troops in Travian.

=head1 METHODS

=head2 new()

  use Travian::Troops::Gauls;

  my $gauls = Travian::Troops::Gauls->new(10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 1);

=cut

sub new
{
	my $class = shift;
	my $self = $class->SUPER::new(@_);

	return $self;
}

sub phalanx { my $self = shift; if (@_) { return ${$self->{'_troops'}}[0] = shift; } else { return $self->{'_troops'}->[0]; } }
sub swordsman { my $self = shift; if (@_) { return ${$self->{'_troops'}}[1] = shift; } else { return $self->{'_troops'}->[1]; } }
sub pathfinder { my $self = shift; if (@_) { return ${$self->{'_troops'}}[2] = shift; } else { return $self->{'_troops'}->[2]; } }
sub theutates_thunder { my $self = shift; if (@_) { return ${$self->{'_troops'}}[3] = shift; } else { return $self->{'_troops'}->[3]; } }
sub druidrider { my $self = shift; if (@_) { return ${$self->{'_troops'}}[4] = shift; } else { return $self->{'_troops'}->[4]; } }
sub haeduan { my $self = shift; if (@_) { return ${$self->{'_troops'}}[5] = shift; } else { return $self->{'_troops'}->[5]; } }
sub battering_ram { my $self = shift; if (@_) { return ${$self->{'_troops'}}[6] = shift; } else { return $self->{'_troops'}->[6]; } }
sub trebuchet { my $self = shift; if (@_) { return ${$self->{'_troops'}}[7] = shift; } else { return $self->{'_troops'}->[7]; } }
sub chieftian { my $self = shift; if (@_) { return ${$self->{'_troops'}}[8] = shift; } else { return $self->{'_troops'}->[8]; } }
sub settler { my $self = shift; if (@_) { return ${$self->{'_troops'}}[9] = shift; } else { return $self->{'_troops'}->[9]; } }
sub hero { my $self = shift; if (@_) { return ${$self->{'_troops'}}[10] = shift; } else { return $self->{'_troops'}->[10]; } }

=head1 AUTHOR

Adrian D. Elgar, E<lt>ade@wasters.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Adrian Elgar

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut

1;
