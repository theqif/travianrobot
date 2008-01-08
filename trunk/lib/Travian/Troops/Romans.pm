package Travian::Troops::Romans;

use strict;
use warnings;

use Carp;
use Travian::Troops;

our @ISA = qw(Travian::Troops);

our $VERSION = '0.01';

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
  $romans->hero(1);

  $romans->legionnaire_attributes();
  $romans->praetorian_attributes();
  $romans->imperian_attributes();
  $romans->equites_legati_attributes();
  $romans->equites_imperatoris_attributes();
  $romans->equites_caesaris_attributes();
  $romans->battering_ram_attributes();
  $romans->fire_catapult_attributes();
  $romans->senator_attributes();
  $romans->settler_attributes();

=head1 DESCRIPTION

This package is for the Roman troops in Travian.

=head1 METHODS

=head2 new()

  use Travian::Troops::Romans;

  my $romans = Travian::Troops::Romans->new(10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 1);

=cut

sub new
{
	my $class = shift;
	my $self = $class->SUPER::new(@_);

	return $self;
}

sub legionnaire { my $self = shift; if (@_) { return ${$self->{'_troops'}}[0] = shift; } else { return $self->{'_troops'}->[0]; } }
sub praetorian { my $self = shift; if (@_) { return ${$self->{'_troops'}}[1] = shift; } else { return $self->{'_troops'}->[1]; } }
sub imperian { my $self = shift; if (@_) { return ${$self->{'_troops'}}[2] = shift; } else { return $self->{'_troops'}->[2]; } }
sub equites_legati { my $self = shift; if (@_) { return ${$self->{'_troops'}}[3] = shift; } else { return $self->{'_troops'}->[3]; } }
sub equites_imperatoris { my $self = shift; if (@_) { return ${$self->{'_troops'}}[4] = shift; } else { return $self->{'_troops'}->[4]; } }
sub equites_caesaris { my $self = shift; if (@_) { return ${$self->{'_troops'}}[5] = shift; } else { return $self->{'_troops'}->[5]; } }
sub battering_ram { my $self = shift; if (@_) { return ${$self->{'_troops'}}[6] = shift; } else { return $self->{'_troops'}->[6]; } }
sub fire_catapult { my $self = shift; if (@_) { return ${$self->{'_troops'}}[7] = shift; } else { return $self->{'_troops'}->[7]; } }
sub senator { my $self = shift; if (@_) { return ${$self->{'_troops'}}[8] = shift; } else { return $self->{'_troops'}->[8]; } }
sub settler { my $self = shift; if (@_) { return ${$self->{'_troops'}}[9] = shift; } else { return $self->{'_troops'}->[9]; } }
sub hero { my $self = shift; if (@_) { return ${$self->{'_troops'}}[10] = shift; } else { return $self->{'_troops'}->[10]; } }

sub legionnaire_attributes { return $_[0]->{'_attributes'}->[0]; }
sub praetorian_attributes { return $_[0]->{'_attributes'}->[1]; }
sub imperian_attributes { return $_[0]->{'_attributes'}->[2]; }
sub equites_legati_attributes { return $_[0]->{'_attributes'}->[3]; }
sub equites_imperatoris_attributes { return $_[0]->{'_attributes'}->[4]; }
sub equites_caesaris_attributes { return $_[0]->{'_attributes'}->[5]; }
sub battering_ram_attributes { return $_[0]->{'_attributes'}->[6]; }
sub fire_catapult_attributes { return $_[0]->{'_attributes'}->[7]; }
sub senator_attributes { return $_[0]->{'_attributes'}->[8]; }
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
