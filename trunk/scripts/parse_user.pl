use Data::Dumper;
my $page = &test_user_page;
my $uhr = &parse_user($page);
print Dumper ($uhr);


sub test_user_page
{
  return<<EOPAGE;
<td class="rbg" colspan="3">Player theqif</td>
<tr><td class="s7">Rank:</td><td class="s7">862</td>
<tr class="s7"><td>Tribe:</td><td>Gauls</td></tr>
<tr class="s7"><td>Alliance:</td><td><a href="http://s3.travian.co.uk/allianz.php?aid=267">~~{M1}~~</a></td></tr>
<tr class="s7"><td>Villages:</td><td>2</td></tr>
<tr class="s7"><td>Population:</td><td>428</td></tr><tr><td></td><td></td></tr>

</tr><tr><td class="s7"><a href="http://s3.travian.co.uk/karte.php?d=288780&amp;c=52">theqif Village</a> <span class="c">(Capital)</span></td>
<td>377</td>
<td>(19|40)</td>
</tr><tr><td class="s7"><a href="http://s3.travian.co.uk/karte.php?d=288781&amp;c=3b">theqifs country rest</a></td>
<td>51</td>
<td>(20|40)</td>
</tr>
EOPAGE
}

sub parse_user
{ 
  my $page   = shift;
  my $player = ();

  if ($page =~ m#<td class="rbg" colspan="3">Player (.+?)</td>#msg) { $player->{name} = $1; }
  if ($page =~ m#<td class="s7">Rank:</td><td class="s7">(\d+?)</td>#msg) { $player->{rank} = $1; }
  if ($page =~ m#<td>Tribe:</td><td>(.+?)</td>#msg) { $player->{tribe} = $1; }
  if ($page =~ m#<a href="http://s3.travian.co.uk/allianz.php?aid=(\d+)">#msg) { $player->{aid} = $1; }
  if ($page =~ m#<td>Villages:</td><td>(\d+?)</td>#msg) { $player->{villages} = $1; }
  if ($page =~ m#<td>Population:</td><td>(\d+?)</td>#msg) { $player->{population} = $1; }

my $kid_ar = [ $page =~ m#<a href="http://s3.travian.co.uk/karte.php\?d=(\d+&amp;c=..)">#msg ];

  $player->{vill_kid} = join ",", @{$kid_ar};


#  my $allies_id_ar = [ $p =~ m#http://s3.travian.co.uk/allianz\.php\?aid=(\d+?)"#mgs ];
#  my $member_id_ar = [ $p =~ m#http://s3.travian.co.uk/spieler\.php\?uid=(\d+?)"#msg ];

#  $hr->{allies}  = $allies_id_ar;
#  $hr->{members} = $member_id_ar;

  return $player;
}
