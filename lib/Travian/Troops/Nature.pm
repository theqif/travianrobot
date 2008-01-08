package Travian::Troops::Nature;

use strict;
use warnings;

use Carp;
use Travian::Troops;

our @ISA = qw(Travian::Troops);

our $VERSION = '0.01';

=head1 NAME

Travian::Troops::Nature - a package that defines Travian Nature troops.

=head1 SYNOPSIS

  use Travian::Troops::Nature;
  my $nature = Travian::Troops::Nature->new();
  $nature->rat(10);
  $nature->spider(20);
  $nature->serpent(30);
  $nature->bat(40);
  $nature->wild_boar(50);
  $nature->wolf(60);
  $nature->bear(70);
  $nature->crocodile(80);
  $nature->tiger(90);
  $nature->elephant(100);

  $nature->rat_attributes();
  $nature->spider_attributes();
  $nature->serpent_attributes();
  $nature->bat_attributes();
  $nature->wild_boar_attributes();
  $nature->wolf_attributes();
  $nature->bear_attributes();
  $nature->crocodile_atributes();
  $nature->tiger_attributes();
  $nature->elephant_attributes();

=head1 DESCRIPTION

This package is for the Nature troops in Travian.

=head1 METHODS

=head2 new()

  use Travian::Troops::Nature;

  my $nature = Travian::Troops::Nature->new(10, 20, 30, 40, 50, 60, 70, 80, 90, 100);

=cut

sub new
{
	my $class = shift;
	my $self = $class->SUPER::new(@_);

	return $self;
}

sub rat { my $self = shift; if (@_) { return ${$self->{'_troops'}}[0] = shift; } else { return $self->{'_troops'}->[0]; } }
sub spider { my $self = shift; if (@_) { return ${$self->{'_troops'}}[1] = shift; } else { return $self->{'_troops'}->[1]; } }
sub serpent { my $self = shift; if (@_) { return ${$self->{'_troops'}}[2] = shift; } else { return $self->{'_troops'}->[2]; } }
sub bat { my $self = shift; if (@_) { return ${$self->{'_troops'}}[3] = shift; } else { return $self->{'_troops'}->[3]; } }
sub wild_boar { my $self = shift; if (@_) { return ${$self->{'_troops'}}[4] = shift; } else { return $self->{'_troops'}->[4]; } }
sub wolf { my $self = shift; if (@_) { return ${$self->{'_troops'}}[5] = shift; } else { return $self->{'_troops'}->[5]; } }
sub bear { my $self = shift; if (@_) { return ${$self->{'_troops'}}[6] = shift; } else { return $self->{'_troops'}->[6]; } }
sub crocodile { my $self = shift; if (@_) { return ${$self->{'_troops'}}[7] = shift; } else { return $self->{'_troops'}->[7]; } }
sub tiger { my $self = shift; if (@_) { return ${$self->{'_troops'}}[8] = shift; } else { return $self->{'_troops'}->[8]; } }
sub elephant { my $self = shift; if (@_) { return ${$self->{'_troops'}}[9] = shift; } else { return $self->{'_troops'}->[9]; } }

sub rat_attributes { return $_[0]->{'_attributes'}->[0]; }
sub spider_attributes { return $_[0]->{'_attributes'}->[1]; }
sub serpent_attributes { return $_[0]->{'_attributes'}->[2]; }
sub bat_attributes { return $_[0]->{'_attributes'}->[3]; }
sub wild_boar_attributes { return $_[0]->{'_attributes'}->[4]; }
sub wolf_attributes { return $_[0]->{'_attributes'}->[5]; }
sub bear_attributes { return $_[0]->{'_attributes'}->[6]; }
sub crocodile_attributes { return $_[0]->{'_attributes'}->[7]; }
sub tiger_attributes { return $_[0]->{'_attributes'}->[8]; }
sub elephant_attributes { return $_[0]->{'_attributes'}->[9]; }

=head1 AUTHOR

Adrian D. Elgar, E<lt>ade@wasters.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Adrian Elgar

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut

1;
