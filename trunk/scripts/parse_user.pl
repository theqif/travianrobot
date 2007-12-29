use Data::Dumper;
my $page = &test_user_page;
my $uhr = &parse_user($page);
print Dumper ($uhr);


sub test_user_page
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

sub parse_user
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


<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd"><html><head><title>Travian uk3</title>


<link rel="stylesheet" type="text/css" href="user_files/new.css">
<link rel="stylesheet" type="text/css" href="user_files/unx.css">
<script src="user_files/unx.js" type="text/javascript"></script>

<meta http-equiv="cache-control" content="no-cache">
<meta http-equiv="pragma" content="no-cache">
<meta http-equiv="expires" content="0">
<meta http-equiv="imagetoolbar" content="no">
<meta http-equiv="content-type" content="text/html; charset=UTF-8"></head><body onload="start()"><div id="ltop1"><div id="ltop5"><a href="http://s3.travian.co.uk/dorf1.php"><img id="n1" src="user_files/x.gif" title="Village Overview"></a><a href="http://s3.travian.co.uk/dorf2.php"><img id="n2" src="user_files/x.gif" title="Village Centre"></a><a href="http://s3.travian.co.uk/karte.php"><img id="n3" src="user_files/x.gif" title="Map"></a><a href="http://s3.travian.co.uk/statistiken.php"><img id="n4" src="user_files/x.gif" title="Statistics"></a><img id="n5" src="user_files/m4.gif" usemap="#nb"><a href="http://s3.travian.co.uk/plus.php"><img id="lplus1" src="user_files/plus.gif" title="Plus Menu" height="100" width="80"></a></div></div><map name="nb"><area shape="rect" coords="0,0,35,100" href="http://s3.travian.co.uk/berichte.php" title="Reports"><area shape="rect" coords="35,0,70,100" href="http://s3.travian.co.uk/nachrichten.php" title="Messages"></map><div id="lmidall"><div id="lmidlc"><div id="lleft">

<a href="http://www.travian.co.uk/"><img class="logo" src="user_files/travian0.gif"></a><table id="navi_table" cellpadding="0" cellspacing="0">
<tbody><tr>
<td class="menu">
<a href="http://www.travian.co.uk/">Homepage</a>
<a href="#" onclick="Popup(0,0); return false;">Manual</a>
<a href="http://s3.travian.co.uk/spieler.php?uid=10092">Profile</a><a href="http://s3.travian.co.uk/logout.php">Logout</a><br><br>
<a href="http://forum.travian.co.uk/" target="_blank">Forum</a><a href="http://www.travian.co.uk/chat/?chatname=uk3%7Ctheqif" target="_blank">Chat</a><br><br><a href="http://s3.travian.co.uk/plus.php?id=3">Travian <b><font color="#71d000">P</font><font color="#ff6f0f">l</font><font color="#71d000">u</font><font color="#ff6f0f">s</font></b></a></td>
</tr>
</tbody></table></div><div id="lmid1"><div id="lmid2"><h1>Player Profile</h1><p class="txt_menue">
<a href="http://s3.travian.co.uk/spieler.php?uid=10092">Overview</a> |
<a href="http://s3.travian.co.uk/spieler.php?s=1">Profile</a> |
<a href="http://s3.travian.co.uk/spieler.php?s=2">Preferences</a> |
<a href="http://s3.travian.co.uk/spieler.php?s=3">Account</a> |
<a href="http://s3.travian.co.uk/spieler.php?s=4">Graphics Pack</a>
</p><p></p><table class="tbg" cellpadding="2" cellspacing="1">
<tbody><tr>
<td class="rbg" colspan="3">Player theqif</td>
</tr>

<tr>
<td colspan="2" width="50%">Details:</td>
<td width="50%">Description:</td>
</tr>

<tr><td colspan="2"></td><td></td></tr>
<tr><td class="s7">Rank:</td><td class="s7">862</td>
<td rowspan="11" class="slr3">Just another one of those happy-go-lucky, merry villages, where us simple folk learn howto love life.<br>
<br>
Proud to have settled our country retreat 21/12/07!!</td></tr>
<tr class="s7"><td>Tribe:</td><td>Gauls</td></tr>
<tr class="s7"><td>Alliance:</td><td><a href="http://s3.travian.co.uk/allianz.php?aid=267">~~{M1}~~</a></td></tr>
<tr class="s7"><td>Villages:</td><td>2</td></tr>
<tr class="s7"><td>Population:</td><td>428</td></tr><tr><td></td><td></td></tr>
<tr class="s7"><td colspan="2"> <a href="http://s3.travian.co.uk/spieler.php?s=1">» Edit profile</a></td></tr>

<tr><td colspan="2" class="slr3">One of the wheat fields has an area given over to special home-blend pipe-weed, my precious yesssss ..</td></tr>
</tbody></table><p>
</p><table class="tbg" cellpadding="2" cellspacing="1">

<tbody><tr>
<td class="rbg" colspan="3">Villages:</td>
</tr>

<tr>
<td width="50%">Name</td>
<td width="25%">Population</td>
<td width="25%">Coordinates</td>
</tr><tr><td class="s7"><a href="http://s3.travian.co.uk/karte.php?d=288780&amp;c=52">theqif Village</a> <span class="c">(Capital)</span></td>
<td>377</td>
<td>(19|40)</td>
</tr><tr><td class="s7"><a href="http://s3.travian.co.uk/karte.php?d=288781&amp;c=3b">theqifs country rest</a></td>
<td>51</td>
<td>(20|40)</td>
</tr></tbody></table></div></div></div><div id="lright1"><a href="http://s3.travian.co.uk/dorf3.php"><span class="f10 c0 s7 b">Villages:</span></a><table class="f10"><tbody><tr><td class="nbr"><span class="c2">•</span>&nbsp; <a href="http://s3.travian.co.uk/spieler.php?newdid=74134&amp;uid=10092" class="active_vl">theqif Village</a></td><td class="right"><table class="dtbl" cellpadding="0" cellspacing="0">
<tbody><tr>
<td class="right dlist1">(19</td>
<td class="center dlist2">|</td>
<td class="left dlist3">40)</td>
</tr>
</tbody></table></td></tr><tr><td class="nbr"><span>•</span>&nbsp; <a href="http://s3.travian.co.uk/spieler.php?newdid=85958&amp;uid=10092">theqifs country rest</a></td><td class="right"><table class="dtbl" cellpadding="0" cellspacing="0">
<tbody><tr>
<td class="right dlist1">(20</td>
<td class="center dlist2">|</td>
<td class="left dlist3">40)</td>
</tr>
</tbody></table></td></tr></tbody></table></div></div><div id="lres0">
<table align="center" cellpadding="0" cellspacing="0"><tbody><tr valign="top">
<td><img class="res" src="user_files/1.gif" title="Wood"></td>
<td id="l4" title="394">5171/11800</td>
<td class="s7"> <img class="res" src="user_files/2.gif" title="Clay"></td>
<td id="l3" title="369">6547/11800</td>
<td class="s7"> <img class="res" src="user_files/3.gif" title="Iron"></td>
<td id="l2" title="313">6564/11800</td><td class="s7"> <img class="res" src="user_files/4.gif" title="Wheat"></td>
<td id="l1" title="206">5451/14400</td>
<td class="s7"> &nbsp;<img class="res" src="user_files/5.gif" title="Wheat consumption">&nbsp;445/651</td></tr></tbody></table>
</div><div id="ltime">Calculated in <b>7</b> ms<br>Server time: <span id="tp1" class="b">15:40:00</span> </div>
<div id="ce"></div></body></html>
