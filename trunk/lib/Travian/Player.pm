package Travian::Player;

use strict;
use warnings;

use Carp;

our $VERSION = '0.01';
our $AUTOLOAD;

my %player_fields = (
	player_name => '',
	player_id => 0,
	tribe => '',
	alliance => '',
	alliance_id => 0,
	rank => 0,
	population => 0,
);

=head1 NAME

Travian::Player - a package that defines a Travian player.

=head1 SYNOPSIS

  use Travian::Player;
  my $player = Travian::Player->new('BigBadBob');
  $player->player_name();
  $player->player_id();
  $player->tribe();
  $player->alliance();
  $player->rank();
  $player->population();

=head1 DESCRIPTION

This package is for a single player in Travian.

=head1 METHODS

=head2 new()

  use Travian::Player;

  my $player = Travian::Player->new('BigBadBob');

=cut

sub new
{
	my $class = shift;
	my $self = {
		_permitted => \%player_fields,
		%player_fields,
	};

	bless $self, $class;

	if (@_)
	{
		$self->player_name(shift);
		$self->player_id(shift);
	}

	return $self;
}

=head2 parse_profife()

  $player->parse_profile($profile_html);

Parse the profile html and populate this player.

=cut

sub parse_profile
{
	my $self = shift;
	my $profile_html = shift;

	if ($profile_html && $profile_html =~ /logout.php/msg)
	{		
		if ($profile_html =~ m#<td class="rbg" colspan="3">Player (.+?)</td>#msg)       { my $player_name = $1; $self->player_name($player_name); }
		if ($profile_html =~ m#<td class="s7">Rank:</td><td class="s7">(\d+?)</td>#msg) { my $rank = $1; $self->rank($rank); }
		if ($profile_html =~ m#<td>Tribe:</td><td>(.+?)</td>#msg)                       { my $tribe = $1; $self->tribe($tribe); }
		if ($profile_html =~ m#allianz.php\?aid=(\d+?)">(.+?)<#msg)                     { my $aid = $1; my $alliance = $2; 
												$self->alliance_id($aid); $self->alliance($alliance); }
		if ($profile_html =~ m#<td>Population:</td><td>(\d+?)</td>#msg)                 { my $pop = $1; $self->population($pop); }

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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Adrian Elgar, Martin Robertson

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut

1;
