package Travian::Report::Header;

use strict;
use warnings;

our $VERSION = '0.01';
our $AUTOLOAD;

use Carp;

my %header_fields = (
	subject => '',
	sent => '',
);

=head1 NAME

Travian::Report::Header - a package that defines a Travian report header.

=head1 SYNOPSIS

  use Travian::Report::Header;
  my $header = Travian::Report::Header->new('A attacks B', '28/12/07 04:42 pm');
  print $header->subject();
  print $header->sent();

=head1 DESCRIPTION

This package is for a single report header in Travian.

=head1 METHODS

=head2 new()

  use Travian::Report::Header;

  my $header = Travian::Report::Header->new($subject, $sent);

=cut

sub new
{
	my $class = shift;
	my $self = {
		_permitted => \%header_fields,
		%header_fields,
	};

	bless $self, $class;

	if (@_)
	{
		$self->subject(shift);
		$self->sent(shift);
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

=head1 SEE ALSO

Travian::Report

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Adrian Elgar, Martin Robertson

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut

1;
