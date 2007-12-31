package Travian::Report;

use strict;
use warnings;

our $VERSION = '0.01';
our $AUTOLOAD;

use Carp;
use Travian::Report::Header;
use Travian::Report::Unit;

my %report_fields = (
	header => undef,
	attacker => undef,	
	defender => undef,
);

=head1 NAME

Travian::Report - a package that defines a Travian report.

=head1 SYNOPSIS

  use Travian::Report;
  my $report = Travian::Report->new('A attacks B', '28/12/07 04:42 pm');
  print $report->header()->subject();
  print $report->header()->sent();

  $report->attacker();
  $report->defender();

=head1 DESCRIPTION

This package is for a single report in Travian.

=head1 METHODS

=head2 new()

  use Travian::Report;

  my $report = Travian::Report->new($subject, $sent);

=cut

sub new
{
	my $class = shift;
	my $self = {
		_permitted => \%report_fields,
		%report_fields,
	};

	bless $self, $class;

	$self->{'header'} = Travian::Report::Header->new();
	$self->{'attacker'} = Travian::Report::Unit->new();
	$self->{'defender'} = Travian::Report::Unit->new();
	
	if (@_)
	{
		$self->{'header'}->subject(shift);
		$self->{'header'}->sent(shift);
	}
	
	return $self;
}

=head2 parse_report()

  $report->parse_report($report_html);
  
Parses the given report html and populates this report.
Returns this report.

=cut

sub parse_report
{
	my $self = shift;
	my $report_html = shift;

	if ($report_html && $report_html =~ m#<h1>Reports</h1>#)
	{
		$report_html =~ s#\n##g;

		$report_html =~ m#<td class="s7">Subject:</td><td class="s7">(.+?)</td>#msg;
		my $subject = $1;
		$report_html =~ m#<td class="s7 b">Sent:</td><td class="s7">(.+?)</td>#msg;
		my $sent = $1;
		$sent =~ s#<span>##;
		$sent =~ s#</span>##;

		$self->{'header'} = Travian::Report::Header->new($subject, $sent);

		my $unit_tables = [ $report_html =~ m#<table.+?class="tbg">(.+?)</table>#msg ];
		foreach my $unit_table (@{$unit_tables})
		{
			$self->{'attacker'}->parse_unit($unit_table) if ($unit_table =~ /Attacker/);
			$self->{'defender'}->parse_unit($unit_table) if ($unit_table =~ /Defender/);
		}

		return $self;
	}

	return;
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

Travian::Report::Header, Travian::Report::Unit

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Adrian Elgar, Martin Robertson

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut

1;
