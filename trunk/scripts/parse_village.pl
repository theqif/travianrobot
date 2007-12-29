use Data::Dumper;

my $page = &test_village_page;
my $vhr = &parse_village($page);

print Dumper ($vhr);

sub test_village_page
{
  return<<EOPAGE;
VID<br>(Capital)</div><div class="f10 b">&nbsp;North Southwitch (21|39)</div><td>Tribe:</td><td> <b>Gauls</b></td><td>Alliance:</td><td><a href="http://s3.travian.co.uk/allianz.php?aid=74">Guardian</a></td><td>Owner:</td><td><a href="http://s3.travian.co.uk/spieler.php?uid=1837"> <b>GodsBrother</b></a></td><td>Population:</td><td><b> 487</b></td><div class="f10 b">&nbsp;Troops:</div><td><img src="village_files/x.gif" border="0" height="12" width="3"></td><td>There is no <br>available information</td><a href="http://s3.travian.co.uk/a2b.php?z=289583">» Send troops</a<a href="http://s3.travian.co.uk/build.php?z=289583&amp;gid=17">» Send merchants</><a href="http://s3.travian.co.uk/karte.php?newdid=74134&amp;d=289583&amp;c=83" class="active_vl">theqif Village</a><td class="right dlist1">(19</td><td class="center dlist2">|</td><td class="left dlist3">40)</td><a href="http://s3.travian.co.uk/karte.php?newdid=85958&amp;d=289583&amp;c=83">theqifs country rest</a><td class="right dlist1">(20</td><td class="center dlist2">|</td><td class="left dlist3">40)</td>
EOPAGE
}

sub parse_village
{
  my $p = shift;
  my $hr = ();


  if ($p =~ m#<td>Name:</td><td>(.+?)</td>#msg)                      { $hr->{name}     = $1; }
  if ($p =~ m#<td>Points:</td><td>(\d+?)</td>#msg)                   { $hr->{points}   = $1; }
  if ($p =~ m#<td>Members:</td><td>(\d+?)</td>#msg)                  { $hr->{nmembers} = $1; }
  if ($p =~ m#<td>Rank:</td><td width="25%">(\d+?)\.</td>#msg)       { $hr->{rank}     = $1; }
  if ($p =~ m#<td class="s7">Tag:</td><td class="s7">(.+?)</td>#msg) { $hr->{tag}      = $1; }
  my $allies_id_ar = [ $p =~ m#http://s3.travian.co.uk/allianz\.php\?aid=(\d+?)"#mgs ];  my $member_id_ar = [ $p =~ m#http://s3.travian.co.uk/spieler\.php\?uid=(\d+?)"#msg ];  $hr->{allies}  = $allies_id_ar;  $hr->{members} = $member_id_ar;

  return $hr;
}

VID
<br>(Capital)</div>
<div class="f10 b">&nbsp;North Southwitch (21|39)</div>
<td>Tribe:</td><td> <b>Gauls</b></td>
<td>Alliance:</td><td><a href="http://s3.travian.co.uk/allianz.php?aid=74">Guardian</a></td>
<td>Owner:</td><td><a href="http://s3.travian.co.uk/spieler.php?uid=1837"> <b>GodsBrother</b></a></td>
<td>Population:</td><td><b> 487</b></td>


<div class="f10 b">&nbsp;Troops:</div>
<td><img src="village_files/x.gif" border="0" height="12" width="3"></td>
<td>There is no <br>available information</td>

<a href="http://s3.travian.co.uk/a2b.php?z=289583">» Send troops</a
<a href="http://s3.travian.co.uk/build.php?z=289583&amp;gid=17">» Send merchants</>
<a href="http://s3.travian.co.uk/karte.php?newdid=74134&amp;d=289583&amp;c=83" class="active_vl">theqif Village</a>
<td class="right dlist1">(19</td>
<td class="center dlist2">|</td>
<td class="left dlist3">40)</td>
<a href="http://s3.travian.co.uk/karte.php?newdid=85958&amp;d=289583&amp;c=83">theqifs country rest</a>
<td class="right dlist1">(20</td>
<td class="center dlist2">|</td>
<td class="left dlist3">40)</td>
