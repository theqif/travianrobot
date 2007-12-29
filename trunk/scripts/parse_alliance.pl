#Alliances have :
# - self URL
# - list of linked alliance URLs
# - rank
# - tag
# - name
# - n points
# - n members
# - list of member URLs

use Data::Dumper;
my $page = &test_alliance_page;
my $ahr = &parse_alliance($page);
print Dumper ($ahr);


sub test_alliance_page
{
  return<<EOPAGE;
<td class="s7">Tag:</td><td class="s7">~~{M1}~~</td>
<td>Name:</td><td>~~{M1}~~</td>
<td>Rank:</td><td width="25%">147.</td>
<td>Points:</td><td>746</td>
<td>Members:</td><td>3</td>

<tr><td colspan="2" class="slr3">Alliances:<div><a href="http://s3.travian.co.uk/allianz.php?aid=395">Knights</a></div><div><a href="http://s3.travian.co.uk/allianz.php?aid=550">*Romans*</a></div><div><a href="http://s3.travian.co.uk/allianz.php?aid=535">Pepper</a></div><div><a href="http://s3.travian.co.uk/allianz.php?aid=127">-</a></div><div><a href="http://s3.travian.co.uk/allianz.php?aid=8">[GMU]</a></div><div><a href="http://s3.travian.co.uk/allianz.php?aid=355">m4</a></div><div><a href="http://s3.travian.co.uk/allianz.php?aid=129">~~{M}~~</a></div><br>

<td class="s7"><a href="http://s3.travian.co.uk/spieler.php?uid=10092">theqif</a></td>
<td class="s7"><a href="http://s3.travian.co.uk/spieler.php?uid=1902">menis54</a></td>
<td class="s7"><a href="http://s3.travian.co.uk/spieler.php?uid=15710">Nostrebor</a></td>
EOPAGE
}



sub parse_alliance
{
  my $p = shift;
  my $hr = ();


  if ($p =~ m#<td>Name:</td><td>(.+?)</td>#msg)                      { $hr->{name}     = $1; }
  if ($p =~ m#<td>Points:</td><td>(\d+?)</td>#msg)                   { $hr->{points}   = $1; }
  if ($p =~ m#<td>Members:</td><td>(\d+?)</td>#msg)                  { $hr->{nmembers} = $1; }
  if ($p =~ m#<td>Rank:</td><td width="25%">(\d+?)\.</td>#msg)       { $hr->{rank}     = $1; }
  if ($p =~ m#<td class="s7">Tag:</td><td class="s7">(.+?)</td>#msg) { $hr->{tag}      = $1; }

  my $allies_id_ar = [ $p =~ m#http://s3.travian.co.uk/allianz\.php\?aid=(\d+?)"#mgs ];
  my $member_id_ar = [ $p =~ m#http://s3.travian.co.uk/spieler\.php\?uid=(\d+?)"#msg ];

  $hr->{allies}  = $allies_id_ar;
  $hr->{members} = $member_id_ar;
  return $hr;
}
