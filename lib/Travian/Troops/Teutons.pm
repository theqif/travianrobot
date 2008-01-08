package Travian::Troops::Teutons;

use strict;
use warnings;

use Carp;
use Travian::Troops;

our @ISA = qw(Travian::Troops);

our $VERSION = '0.01';

=head1 NAME

Travian::Troops::Teutons - a package that defines Travian Teuton troops.

=head1 SYNOPSIS

  use Travian::Troops::Teutons;
  my $teutons = Travian::Troops::Teutons->new();
  $teutons->clubswinger(10);
  $teutons->spearman(20);
  $teutons->axeman(30);
  $teutons->scout(40);
  $teutons->paladin(50);
  $teutons->teutonic_knight(60);
  $teutons->battering_ram(70);
  $teutons->catapult(80);
  $teutons->chief(90);
  $teutons->settler(100);
  $teutons->hero(1);

  $teutons->clubswinger_attributes();
  $teutons->spearman_attributes();
  $teutons->axeman_attributes();
  $teutons->scout_attributes();
  $teutons->paladin_attributes();
  $teutons->teutonic_knight_attributes();
  $teutons->battering_ram_attributes();
  $teutons->catapult_atributes();
  $teutons->chief_attributes();
  $teutons->settler_attributes();

=head1 DESCRIPTION

This package is for the Teuton troops in Travian.

=head1 METHODS

=head2 new()

  use Travian::Troops::Teutons;

  my $teutons = Travian::Troops::Teutons->new(10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 1);

=cut

sub new
{
	my $class = shift;
	my $self = $class->SUPER::new(@_);

	return $self;
}

sub clubswinger { my $self = shift; if (@_) { return ${$self->{'_troops'}}[0] = shift; } else { return $self->{'_troops'}->[0]; } }
sub spearman { my $self = shift; if (@_) { return ${$self->{'_troops'}}[1] = shift; } else { return $self->{'_troops'}->[1]; } }
sub axeman { my $self = shift; if (@_) { return ${$self->{'_troops'}}[2] = shift; } else { return $self->{'_troops'}->[2]; } }
sub scout { my $self = shift; if (@_) { return ${$self->{'_troops'}}[3] = shift; } else { return $self->{'_troops'}->[3]; } }
sub paladin { my $self = shift; if (@_) { return ${$self->{'_troops'}}[4] = shift; } else { return $self->{'_troops'}->[4]; } }
sub teutonic_knight { my $self = shift; if (@_) { return ${$self->{'_troops'}}[5] = shift; } else { return $self->{'_troops'}->[5]; } }
sub battering_ram { my $self = shift; if (@_) { return ${$self->{'_troops'}}[6] = shift; } else { return $self->{'_troops'}->[6]; } }
sub catapult { my $self = shift; if (@_) { return ${$self->{'_troops'}}[7] = shift; } else { return $self->{'_troops'}->[7]; } }
sub chief { my $self = shift; if (@_) { return ${$self->{'_troops'}}[8] = shift; } else { return $self->{'_troops'}->[8]; } }
sub settler { my $self = shift; if (@_) { return ${$self->{'_troops'}}[9] = shift; } else { return $self->{'_troops'}->[9]; } }
sub hero { my $self = shift; if (@_) { return ${$self->{'_troops'}}[10] = shift; } else { return $self->{'_troops'}->[10]; } }

sub clubswinger_attributes { return $_[0]->{'_attributes'}->[0]; }
sub spearman_attributes { return $_[0]->{'_attributes'}->[1]; }
sub axeman_attributes { return $_[0]->{'_attributes'}->[2]; }
sub scout_attributes { return $_[0]->{'_attributes'}->[3]; }
sub paladin_attributes { return $_[0]->{'_attributes'}->[4]; }
sub teutonic_knight_attributes { return $_[0]->{'_attributes'}->[5]; }
sub battering_ram_attributes { return $_[0]->{'_attributes'}->[6]; }
sub catapult_attributes { return $_[0]->{'_attributes'}->[7]; }
sub chief_attributes { return $_[0]->{'_attributes'}->[8]; }
sub settler_attributes { return $_[0]->{'_attributes'}->[9]; }

=head1 AUTHOR

Adrian D. Elgar, E<lt>ade@wasters.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Adrian Elgar

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut

1;
