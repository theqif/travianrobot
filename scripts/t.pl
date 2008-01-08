use lib '../lib';
use Data::Dumper;
use Travian;
use strict;
use Carp;

my $UA = "Mozilla/5.0 (Macintosh; U; Intel Mac OS X; en-US; rv:1.8.1.11) Gecko/20071127 Firefox/2.0.0.11";

my $server = shift;
my $user   = shift;
my $pass   = shift;
my $fvid   = shift;
my $tx     = shift;
my $ty     = shift;

my $w = shift; my $c = shift; my $i = shift; my $wh = shift;

#perl send_resources.pl 3 theqif fish 74134 19 41 50 50 50 50
die "usage: $0 [server] [user] [pass] [from_vid] [to_x][to_y] [wood][clay][iron][wheat]\n" unless $server && $user && $pass && $fvid && $tx && $ty && $w&&$c&&$i&&$wh;


my $t = Travian->new($server, agent => $UA);

if (!$t->login($user, $pass))
{
        croak $t->error_msg();
}


http://help.travian.co.uk/index.php?type=faq&mod=420
my $url = $t->base_url . "build.php";

#id=>19 is set - refers to the city square where the merchants are based - not sure _why_
my $ar  = [id=>19, dname=>"", x=>$tx, y=>$ty, x2=>'', r1=>$w, r2=>$c, r3=>$i, r4=>$wh, s1=>'ok', ];

$t->village($fvid);
my $res = $t->post($url, $ar);

croak "Couldnt post : " . Dumper ($res) unless ($res->is_success);

my $car = &confirm_merchant_send($t,$res->content());

#can get duration & nMerchants from $car now .. but how?
#unshift (@{$car}); unshift (@{$car}); unshift (@{$car}); unshift (@{$car});
#print Dumper ($car); exit;

my $cres = $t->post($url, $car);

croak "Couldnt confirm : " . Dumper ($cres) unless ($cres->is_success);

print "Done!\n";

sub confirm_merchant_send
{
  my $s = shift;
  my $p = shift;

  my ($a,$sz,$kid);
  if ($p =~ m#name="a" value="(\d+?)"#msg) { $a   = $1; }
  if ($p =~ m#ame="sz" value="(\d+?)"#msg) { $sz  = $1; }
  if ($p =~ m#me="kid" value="(\d+?)"#msg) { $kid = $1; }

  my ($r1,$r2,$r3,$r4);
  if ($p =~ m#name="r1" value="(\d+?)"#msg) { $r1 = $1; }
  if ($p =~ m#name="r2" value="(\d+?)"#msg) { $r2 = $1; }
  if ($p =~ m#name="r3" value="(\d+?)"#msg) { $r3 = $1; }
  if ($p =~ m#name="r4" value="(\d+?)"#msg) { $r4 = $1; }


  my ($dur, $mer);
  if ($p =~ m#<td>Duration:</td><td>(\d:\d\d:\d\d)</td>#msg) { $dur = $1; }
  if ($p =~ m#<td>Merchants:</td><td>(\d+?)</td>#msg)        { $mer = $1; }

  return [id=>19, r1=>$r1, r2=>$r2, r3=>$r3, r4=>$r4, x2=>'', s1=>'ok', a=>$a, sz=>$sz, kid=>$kid, dur=>$dur, mer=>$mer];
}

<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
	<title>&#x005C;travian&#x005C;faq - Gallic Troops</title>
	<!--[if IE]><link rel="stylesheet" type="text/css" href="includes/css/style_1_ie_7.css" /><![endif]-->
	<!--[if lte IE 6]><link rel="stylesheet" type="text/css" href="includes/css/style_1_ie_6.css" /><![endif]-->
	<!--[if !IE]>--><link rel="stylesheet" type="text/css" href="includes/css/style_1.css" /><!--<![endif]-->
	<script src="includes/js/script.js" type="text/javascript"></script>
	<link rel="icon" href="images/ico/travian_faq.ico" type="image/ico" />

	<meta name="robots" content="index, follow" />
	<meta name="author" content="Travian Games GmbH" />
	<meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
</head>
<body>
	<div id="flagbox">
		<div class="layer_box">
			<div id="country_box" onclick="country_box_change(event)">
				<table style="align:left;">
					<tr><td style="width:26px;"><img src="images/flags/en.gif" class="fimg" alt="en" /></td><td>&nbsp;English</td><td style="width:15px;"><img src="images/down.jpg" alt="" /></td></tr>

				</table>
			</div>
			<div id="country_text"><table><tr><td>The Travian FAQ in your language:</td></tr></table></div>
			<div id="flags" onmouseout="country_box_change(event)"><table><tr><td><a href="http://help.travian.cat/"><img src="images/flags/cat.gif" class="fimg" alt="br" title="br" /></a></td><td><a href="http://help.travian.cat/">català</a></td></tr><tr><td><a href="http://help.travian.cz/"><img src="images/flags/cz.gif" class="fimg" alt="cz" title="cz" /></a></td><td><a href="http://help.travian.cz/">Česk</a></td></tr><tr><td><a href="http://help.travian.cn/"><img src="images/flags/cn.gif" class="fimg" alt="cn" title="cn" /></a></td><td><a href="http://help.travian.cn/">Chinese</a></td></tr><tr><td><a href="http://help.travian.dk/"><img src="images/flags/dk.gif" class="fimg" alt="dk" title="dk" /></a></td><td><a href="http://help.travian.dk/">Danish</a></td></tr><tr><td><a href="http://help.travian.de/"><img src="images/flags/de.gif" class="fimg" alt="de" title="de" /></a></td><td><a href="http://help.travian.de/">Deutsch</a></td></tr><tr><td><a href="http://help.travian.com/"><img src="images/flags/com.gif" class="fimg" alt="com" title="com" /></a></td><td><a href="http://help.travian.com/">English</a></td></tr><tr><td><a href="http://help.travian3.com.ar/"><img src="images/flags/ar.gif" class="fimg" alt="net" title="net" /></a></td><td><a href="http://help.travian3.com.ar/">Español - Argentina</a></td></tr><tr><td><a href="http://help.travian.com.hr/"><img src="images/flags/hr.gif" class="fimg" alt="fr" title="fr" /></a></td><td><a href="http://help.travian.com.hr/">Hrvatski</a></td></tr><tr><td><a href="http://help.travian3.it/"><img src="images/flags/it.gif" class="fimg" alt="it" title="it" /></a></td><td><a href="http://help.travian3.it/">Italiano</a></td></tr><tr><td><a href="http://help.travian.hu/"><img src="images/flags/hu.gif" class="fimg" alt="hu" title="hu" /></a></td><td><a href="http://help.travian.hu/">Magyar</a></td></tr><tr><td><a href="http://help.travian.nl/"><img src="images/flags/nl.gif" class="fimg" alt="nl" title="nl" /></a></td><td><a href="http://help.travian.nl/">Nederlands</a></td></tr><tr><td><a href="http://help.travian.no/"><img src="images/flags/no.gif" class="fimg" alt="no" title="no" /></a></td><td><a href="http://help.travian.no/">Norsk</a></td></tr><tr><td><a href="http://help.travian3.pl/"><img src="images/flags/pl.gif" class="fimg" alt="pl" title="pl" /></a></td><td><a href="http://help.travian3.pl/">Polska</a></td></tr><tr><td><a href="http://help.travian.com.pt/"><img src="images/flags/pt.gif" class="fimg" alt="pt" title="pt" /></a></td><td><a href="http://help.travian.com.pt/">Português</a></td></tr><tr><td><a href="http://help.travian.ru/"><img src="images/flags/ru.gif" class="fimg" alt="ru" title="ru" /></a></td><td><a href="http://help.travian.ru/">Российя</a></td></tr><tr><td><a href="http://help.travian.bg/"><img src="images/flags/bg.gif" class="fimg" alt="bg" title="bg" /></a></td><td><a href="http://help.travian.bg/">България</a></td></tr><tr><td><a href="http://help.travian.ro/"><img src="images/flags/ro.gif" class="fimg" alt="ro" title="ro" /></a></td><td><a href="http://help.travian.ro/">România</a></td></tr><tr><td><a href="http://help.travian.sk/"><img src="images/flags/sk.gif" class="fimg" alt="sk" title="sk" /></a></td><td><a href="http://help.travian.sk/">Slovensk</a></td></tr><tr><td><a href="http://help.travian.si/"><img src="images/flags/si.gif" class="fimg" alt="si" title="si" /></a></td><td><a href="http://help.travian.si/">slovenščina</a></td></tr><tr><td><a href="http://help.travian.fi/"><img src="images/flags/fi.gif" class="fimg" alt="fi" title="fi" /></a></td><td><a href="http://help.travian.fi/">suomi</a></td></tr><tr><td><a href="http://help.travian.se/"><img src="images/flags/se.gif" class="fimg" alt="se" title="se" /></a></td><td><a href="http://help.travian.se/">Swedish</a></td></tr><tr><td><a href="http://help.travian.com.tr/"><img src="images/flags/tr.gif" class="fimg" alt="tr" title="tr" /></a></td><td><a href="http://help.travian.com.tr/">Türkiye</a></td></tr><tr><td><a href="http://help.travian.hk/"><img src="images/flags/hk.gif" class="fimg" alt="hk" title="hk" /></a></td><td><a href="http://help.travian.hk/">繁體中文</a></td></tr></table></div></div>

	</div>
	<div id="headbox"></div>
	<div id="mainbox">
		<ul id="navbox">
			<li><a class="treenode " href="index.php?type=start&amp;mod=100">Start</a>
		<ul>
			<li><a href="index.php?type=archive&amp;mod=110">Archive</a></li>
			<li><a href="index.php?type=faq&amp;mod=120">Links</a></li></ul></li>

			<li><a class="treenode " href="index.php?type=faq&amp;mod=200">Tutorials</a>
		<ul>
			<li><a href="index.php?type=faq&amp;mod=230">Create Worldmaps</a></li>
			<li><a href="index.php?type=faq&amp;mod=210">Text Tutorials</a></li>
			<li><a href="index.php?type=faq&amp;mod=220">Video Tutorials</a></li></ul></li>
			<li><a class="treenode " href="index.php?type=faq&amp;mod=300">Buildings</a>

		<ul>
			<li><a href="index.php?type=faq&amp;mod=301">Building Overview</a></li>
			<li><a href="index.php?type=faq&mod=300#buildingtree">Buildingtree</a></li>
			<li><a class="treenode " href="index.php?type=faq&amp;mod=358">Infrastructure</a>
		<ul>
			<li><a href="index.php?type=faq&amp;mod=360">Brewery</a></li>
			<li><a href="index.php?type=faq&amp;mod=362">Cranny</a></li>

			<li><a href="index.php?type=faq&amp;mod=364">Embassy</a></li>
			<li><a href="index.php?type=faq&amp;mod=366">Main Building</a></li>
			<li><a href="index.php?type=faq&amp;mod=368">Marketplace</a></li>
			<li><a href="index.php?type=faq&amp;mod=370">Palace</a></li>
			<li><a href="index.php?type=faq&amp;mod=372">Residence</a></li>
			<li><a href="index.php?type=faq&amp;mod=374">Stonemason</a></li>

			<li><a href="index.php?type=faq&amp;mod=376">Townhall</a></li>
			<li><a href="index.php?type=faq&amp;mod=378">Trade Office</a></li>
			<li><a href="index.php?type=faq&amp;mod=380">Treasury</a></li>
			<li><a href="index.php?type=faq&amp;mod=382">Wonder Of The World</a></li></ul></li>
			<li><a class="treenode " href="index.php?type=faq&amp;mod=326">Military</a>
		<ul>

			<li><a href="index.php?type=faq&amp;mod=328">Academy</a></li>
			<li><a href="index.php?type=faq&amp;mod=330">Armoury</a></li>
			<li><a href="index.php?type=faq&amp;mod=332">Barracks</a></li>
			<li><a href="index.php?type=faq&amp;mod=334">Blacksmith</a></li>
			<li><a href="index.php?type=faq&amp;mod=336">City Wall</a></li>
			<li><a href="index.php?type=faq&amp;mod=338">Earth Wall</a></li>

			<li><a href="index.php?type=faq&amp;mod=340">Great Barracks</a></li>
			<li><a href="index.php?type=faq&amp;mod=342">Great Stable</a></li>
			<li><a href="index.php?type=faq&amp;mod=344">Hero&#x0027;s Mansion</a></li>
			<li><a href="index.php?type=faq&amp;mod=346">Palisade</a></li>
			<li><a href="index.php?type=faq&amp;mod=348">Rally Point</a></li>
			<li><a href="index.php?type=faq&amp;mod=350">Stable</a></li>

			<li><a href="index.php?type=faq&amp;mod=352">Tournament Square</a></li>
			<li><a href="index.php?type=faq&amp;mod=354">Trapper</a></li>
			<li><a href="index.php?type=faq&amp;mod=356">Workshop</a></li></ul></li>
			<li><a class="treenode " href="index.php?type=faq&amp;mod=302">Resources</a>
		<ul>
			<li><a href="index.php?type=faq&amp;mod=304">Bakery</a></li>

			<li><a href="index.php?type=faq&amp;mod=306">Brickyard</a></li>
			<li><a href="index.php?type=faq&amp;mod=308">Clay Pit</a></li>
			<li><a href="index.php?type=faq&amp;mod=310">Cropland</a></li>
			<li><a href="index.php?type=faq&amp;mod=312">Grain Mill</a></li>
			<li><a href="index.php?type=faq&amp;mod=314">Granary</a></li>
			<li><a href="index.php?type=faq&amp;mod=315">Great Granary</a></li>

			<li><a href="index.php?type=faq&amp;mod=317">Great Warehouse</a></li>
			<li><a href="index.php?type=faq&amp;mod=316">Iron Foundry</a></li>
			<li><a href="index.php?type=faq&amp;mod=318">Iron Mine</a></li>
			<li><a href="index.php?type=faq&amp;mod=320">Sawmill</a></li>
			<li><a href="index.php?type=faq&amp;mod=322">Warehouse</a></li>
			<li><a href="index.php?type=faq&amp;mod=324">Woodcutter</a></li></ul></li>

			<li><a href="index.php?type=faq&mod=300#villagecenter">Village Center</a></li>
			<li><a href="index.php?type=faq&mod=300#villageoverview">Village Overview</a></li></ul></li>
			<li><a class="treenode " href="index.php?type=faq&amp;mod=400">Troops</a>
		<ul>
			<li><a href="index.php?type=faq&amp;mod=420">Gallic Troops</a></li>
			<li><a href="index.php?type=faq&amp;mod=450">Heroes</a></li>

			<li><a href="index.php?type=faq&amp;mod=460">Natarian Troops</a></li>
			<li><a href="index.php?type=faq&amp;mod=440">Nature&#x0027;s Troops</a></li>
			<li><a href="index.php?type=faq&amp;mod=410">Roman Troops</a></li>
			<li><a href="index.php?type=faq&amp;mod=430">Teutonic Troops</a></li></ul></li>
			<li><a class="treenode " href="index.php?type=faq&amp;mod=500">Game</a>
		<ul>

			<li><a href="index.php?type=faq&amp;mod=504">Alliances</a></li>
			<li><a href="index.php?type=faq&amp;mod=508">Artifacts</a></li>
			<li><a href="index.php?type=faq&amp;mod=512">Beginner&#x0027;s Protection</a></li>
			<li><a href="index.php?type=faq&amp;mod=516">Canceling Actions</a></li>
			<li><a href="index.php?type=faq&amp;mod=520">Capitals</a></li>
			<li><a href="index.php?type=faq&amp;mod=524">Changelog</a></li>

			<li><a href="index.php?type=faq&amp;mod=528">Conquering Villages</a></li>
			<li><a href="index.php?type=faq&amp;mod=532">Culture Points</a></li>
			<li><a href="index.php?type=faq&amp;mod=572">Game Rules</a></li>
			<li><a href="index.php?type=faq&amp;mod=536">Getting Farmed</a></li>
			<li><a href="index.php?type=faq&amp;mod=540">Interacting With Others</a></li>
			<li><a href="index.php?type=faq&amp;mod=544">Map</a></li>

			<li><a href="index.php?type=faq&amp;mod=548">Messages & Reports</a></li>
			<li><a href="index.php?type=faq&amp;mod=588">Miscellaneous</a></li>
			<li><a href="index.php?type=faq&amp;mod=552">New Villages</a></li>
			<li><a href="index.php?type=faq&amp;mod=556">Oases</a></li>
			<li><a href="index.php?type=faq&amp;mod=560">Population</a></li>
			<li><a href="index.php?type=faq&amp;mod=564">Preventing Conquerings</a></li>

			<li><a href="index.php?type=faq&amp;mod=568">Problems With Crop</a></li>
			<li><a href="index.php?type=faq&amp;mod=576">Statistics</a></li>
			<li><a href="index.php?type=faq&amp;mod=580">Travian Plus & Gold</a></li>
			<li><a href="index.php?type=faq&amp;mod=584">Tribes</a></li></ul></li>
			<li><a class="treenode " href="index.php?type=faq&amp;mod=600">Preferences</a>
		<ul>

			<li><a href="index.php?type=faq&amp;mod=610">Account Preferences</a></li>
			<li><a href="index.php?type=faq&amp;mod=630">Graphic Packs</a></li>
			<li><a href="index.php?type=faq&amp;mod=650">Player Profile</a></li>
			<li><a href="index.php?type=faq&amp;mod=640">Plus Preferences</a></li>
			<li><a href="index.php?type=faq&amp;mod=620">Renaming Villages</a></li></ul></li>
			<li><a class="treenode " href="index.php?type=faq&amp;mod=700">IRC</a>

		<ul>
			<li><a href="index.php?type=faq&amp;mod=735">Channels</a></li>
			<li><a href="index.php?type=faq&amp;mod=745">IRC Rules</a></li>
			<li><a href="index.php?type=faq&amp;mod=740">Memos</a></li>
			<li><a class="external " href="http://www.vulnscan.org/UnrealIRCd/unreal32docs.html">Network</a></li>
			<li><a href="index.php?type=faq&amp;mod=730">Nicknames</a></li>

			<li><a class="treenode " href="index.php?type=faq&amp;mod=750">Services</a>
		<ul>
			<li><a class="external " href="http://dev.anope.org/docgen/en_us/BotServ.php">BotServ</a></li>
			<li><a class="external " href="http://dev.anope.org/docgen/en_us/ChanServ.php">ChanServ</a></li>
			<li><a class="external " href="http://dev.anope.org/docgen/en_us/HostServ.php">HostServ</a></li>
			<li><a class="external " href="http://dev.anope.org/docgen/en_us/MemoServ.php">MemoServ</a></li>

			<li><a class="external " href="http://dev.anope.org/docgen/en_us/NickServ.php">NickServ</a></li>
			<li><a class="external " href="http://dev.anope.org/docgen/en_us/OperServ.php">OperServ</a></li></ul></li>
			<li><a class="treenode " href="index.php?type=faq&amp;mod=705">Tutorials</a>
		<ul>
			<li><a href="index.php?type=faq&amp;mod=710">Chatzilla</a></li>
			<li><a href="index.php?type=faq&amp;mod=715">Miranda</a></li>

			<li><a href="index.php?type=faq&amp;mod=720">Mirc</a></li>
			<li><a href="index.php?type=faq&amp;mod=725">Trillian</a></li></ul></li></ul></li>
			<li><a class="treenode " href="index.php?type=faq&amp;mod=800">Dictionary</a>
		<ul>
			<li><a href="index.php?type=faq&amp;mod=810">Buildings</a></li>
			<li><a href="index.php?type=faq&amp;mod=840">Forum/Chat</a></li>

			<li><a href="index.php?type=faq&amp;mod=830">Game</a></li>
			<li><a href="index.php?type=faq&amp;mod=850">Smilies/Emoticons</a></li>
			<li><a href="index.php?type=faq&amp;mod=860">Travian-Team</a></li>
			<li><a href="index.php?type=faq&amp;mod=820">Troops</a></li></ul></li>
			<li><a class="noexpand " href="index.php?type=sitemap&amp;mod=900">Sitemap</a></li></ul>
		<div id="contentbox">

			
<h1>Gallic Troops</h1><table class="tbg" cellpadding="2" cellspacing="1"><tbody>
<tr class="rbg"><td colspan="11">Trainingcosts and attributes</td></tr>
<tr class="cbg1">
<td colspan="2">&nbsp;</td>
<td><img src="images/misc/att_all.gif" alt="Attack value" title="Attack value" style="border: 0px none ; height: 16px; width: 16px;" /></td>
<td><img src="images/misc/def_i.gif" alt="Defense value against infantry." title="Defense value against infantry." style="border: 0px none ; height: 16px; width: 16px;" /></td>
<td><img src="images/misc/def_c.gif" alt="Defense value against cavalry" title="Defense value against cavalry" style="border: 0px none ; height: 16px; width: 16px;" /></td>
<td><img src="images/misc/holz.gif" alt="Lumber" style="border: 0px none ; height: 12px; width: 18px;" /></td>
<td><img src="images/misc/lehm.gif" alt="Clay" style="border: 0px none ; height: 12px; width: 18px;" /></td>
<td><img src="images/misc/eisen.gif" alt="Iron" style="border: 0px none ; height: 12px; width: 18px;" /></td>
<td><img src="images/misc/getreide.gif" alt="Crop" style="border: 0px none ; height: 12px; width: 18px;" /></td>
<td><img src="images/misc/verbrauch.gif" alt="Crop usage" style="border: 0px none ; height: 12px; width: 18px;" /></td>
<td>Velocity</td>

</tr>
<tr><td style="width: 25px; text-align: center;"><img src="images/troops/tid21.gif" style="border: 0px none ; height: 16px; width: 16px;" alt="Phalanx" /></td><td class="s7" style="width: 135px;"><span class="f9" style="white-space: nowrap;"><a href="#tid21">Phalanx</a></span></td><td style="width: 25px;">15</td><td>40</td><td>50</td><td>100</td><td>130</td><td>55</td><td>30</td><td>1</td><td>7</td></tr><tr><td style="width: 25px; text-align: center;"><img src="images/troops/tid22.gif" style="border: 0px none ; height: 16px; width: 16px;" alt="Swordsman" /></td><td class="s7" style="width: 135px;"><span class="f9" style="white-space: nowrap;"><a href="#tid22">Swordsman</a></span></td><td style="width: 25px;">65</td><td>35</td><td>20</td><td>140</td><td>150</td><td>185</td><td>60</td><td>1</td><td>6</td></tr><tr><td style="width: 25px; text-align: center;"><img src="images/troops/tid23.gif" style="border: 0px none ; height: 16px; width: 16px;" alt="Pathfinder" /></td><td class="s7" style="width: 135px;"><span class="f9" style="white-space: nowrap;"><a href="#tid23">Pathfinder</a></span></td><td style="width: 25px;">0</td><td>20</td><td>10</td><td>170</td><td>150</td><td>20</td><td>40</td><td>2</td><td>17</td></tr><tr><td style="width: 25px; text-align: center;"><img src="images/troops/tid24.gif" style="border: 0px none ; height: 16px; width: 16px;" alt="Theutates Thunder" /></td><td class="s7" style="width: 135px;"><span class="f9" style="white-space: nowrap;"><a href="#tid24">Theutates Thunder</a></span></td><td style="width: 25px;">90</td><td>25</td><td>40</td><td>350</td><td>450</td><td>230</td><td>60</td><td>2</td><td>19</td></tr><tr><td style="width: 25px; text-align: center;"><img src="images/troops/tid25.gif" style="border: 0px none ; height: 16px; width: 16px;" alt="Druidrider" /></td><td class="s7" style="width: 135px;"><span class="f9" style="white-space: nowrap;"><a href="#tid25">Druidrider</a></span></td><td style="width: 25px;">45</td><td>115</td><td>55</td><td>360</td><td>330</td><td>280</td><td>120</td><td>2</td><td>16</td></tr><tr><td style="width: 25px; text-align: center;"><img src="images/troops/tid26.gif" style="border: 0px none ; height: 16px; width: 16px;" alt="Haeduan" /></td><td class="s7" style="width: 135px;"><span class="f9" style="white-space: nowrap;"><a href="#tid26">Haeduan</a></span></td><td style="width: 25px;">140</td><td>50</td><td>165</td><td>500</td><td>620</td><td>675</td><td>170</td><td>3</td><td>13</td></tr><tr><td style="width: 25px; text-align: center;"><img src="images/troops/tid27.gif" style="border: 0px none ; height: 16px; width: 16px;" alt="Ram" /></td><td class="s7" style="width: 135px;"><span class="f9" style="white-space: nowrap;"><a href="#tid27">Ram</a></span></td><td style="width: 25px;">50</td><td>30</td><td>105</td><td>950</td><td>555</td><td>330</td><td>75</td><td>3</td><td>4</td></tr><tr><td style="width: 25px; text-align: center;"><img src="images/troops/tid28.gif" style="border: 0px none ; height: 16px; width: 16px;" alt="Trebuchet" /></td><td class="s7" style="width: 135px;"><span class="f9" style="white-space: nowrap;"><a href="#tid28">Trebuchet</a></span></td><td style="width: 25px;">70</td><td>45</td><td>10</td><td>960</td><td>1450</td><td>630</td><td>90</td><td>6</td><td>3</td></tr><tr><td style="width: 25px; text-align: center;"><img src="images/troops/tid29.gif" style="border: 0px none ; height: 16px; width: 16px;" alt="Chieftain" /></td><td class="s7" style="width: 135px;"><span class="f9" style="white-space: nowrap;"><a href="#tid29">Chieftain</a></span></td><td style="width: 25px;">40</td><td>50</td><td>50</td><td>30750</td><td>45400</td><td>31000</td><td>37500</td><td>4</td><td>5</td></tr><tr><td style="width: 25px; text-align: center;"><img src="images/troops/tid30.gif" style="border: 0px none ; height: 16px; width: 16px;" alt="Settler" /></td><td class="s7" style="width: 135px;"><span class="f9" style="white-space: nowrap;"><a href="#tid30">Settler</a></span></td><td style="width: 25px;">0</td><td>80</td><td>80</td><td>5500</td><td>7000</td><td>5300</td><td>4900</td><td>1</td><td>5</td></tr></tbody></table>

 <h2><a id="tid21">Phalanx</a></h2>
 <table border="0"> <tr> <td> <img src="images/troops/u21.gif" alt="Phalanx" title="Phalanx" style="border:0px;float: left;" /> </td> <td>

 <p> <b>Prerequisites:</b> Barracks level 1<br /> Being infantry, the Phalanx is cheap and fast to produce. Their attack power is low though. But in the defense they are quite strong against infantry and cavalry. </p>

 <ul> <li>Research: 0 Lumber, 0 Clay, 0 Iron, 0 Crop, Length: /</li> 

<li>Velocity: 7 Fields/Hour</li> 
<li>Load capacity: 30 Resources</li> 
<li>Upkeep: 1 Crop per hour</li> 
<li>Length of training: 0:21:40 for barracks level 1</li> </ul> </td> </tr> </table> 


<h2><a id="tid22">Swordsman</a></h2> 

<table border="0"> <tr> <td> <img src="images/troops/u22.gif" alt="Swordsman" title="Swordsman" style="border:0px;float: left;" /> </td> <td> <p> 

 <b>Prerequisites:</b> Academy level 1, Blacksmith level 1<br />
 The Swordsmans are more expensive than the Phalanx, But they are an attacking unit. Defensively they are quite weak, especially against cavalry. </p> <ul> 

<li>Research: 940 Lumber, 700 Clay, 1680 Iron, 520 Crop, Length: 02:00:00</li>
<li>Velocity: 6 Fields/Hour</li> 
<li>Load capacity: 45 Resources</li> 
<li>Upkeep: 1 Crop per hour</li> 
<li>Length of training: 0:30:00 for barracks level 1</li> </ul> </td> </tr> </table> 

 <h2><a id="tid23">Pathfinder</a></h2> <table border="0"> <tr> <td> <img src="images/troops/u23.gif" alt="Pathfinder" title="Pathfinder" style="border:0px;float: left;" /> </td> <td> <p> 

 <b>Prerequisites:</b> Academy level 5, Stable level 1<br /> The Pathfinder is the Gaul&#x0027;s reconnaissance unit. They are very fast and carefully they advance on the enemy units, resources or buildings to spy them out. If there aren&#x0027;t any Equites Legati, scouts or pathfinders in the scouted village, the scouting remains unnoticed or if you don&#x0027;t loose any of your own. </p> <ul> 

<li>Research: 1120 Lumber, 700 Clay, 360 Iron, 400 Crop, Length: 01:55:00</li> 
<li>Velocity: 17 Fields/Hour</li> 
<li>Load capacity: 0 Resources</li> 
<li>Upkeep: 2 Crop per hour</li> 
<li>Length of training: 0:28:20 for stable level 1</li> </ul> </td> </tr> </table> 

 <h2><a id="tid24">Theutates Thunder</a></h2> <table border="0"> <tr> <td> <img src="images/troops/u24.gif" alt="Theutates Thunder" title="Theutates Thunder" style="border:0px;float: left;" /> </td> <td> <p> 

 <b>Prerequisites:</b> Academy level 5, Stable level 3<br /> Theutates Thunders are very fast and powerful cavalry units, which can carry a large amount of resources. So they are excellent raiders, too. In defense their abilities are average at best. </p> <ul> 

<li>Research: 2200 Lumber, 1900 Clay, 2040 Iron, 520 Crop, Length: 03:05:00</li> 
<li>Velocity: 19 Fields/Hour</li> 
<li>Load capacity: 75 Resources</li> 
<li>Upkeep: 2 Crop per hour</li> 
<li>Length of training: 0:51:40 for stable level 1</li> </ul> </td> </tr> </table> 

 <h2><a id="tid25">Druidrider</a></h2> <table border="0"> <tr> <td> <img src="images/troops/u25.gif" alt="Druidrider" title="Druidrider" style="border:0px;float: left;" /> </td> <td> <p> 

 <b>Prerequisites:</b> Academy level 5, Stable level 5<br /> This medium cavalry unit is brilliant at defense against enemy infantry. But its costs and supply are relatively expensive. </p> <ul> 

<li>Research: 2260 Lumber, 1420 Clay, 2440 Iron, 880 Crop, Length: 03:10:00</li> 
<li>Velocity: 16 Fields/Hour</li> 
<li>Load capacity: 35 Resources</li> 
<li>Upkeep: 2 Crop per hour</li> 
<li>Length of training: 0:53:20 for stable level 1</li> </ul> </td> </tr> </table> 
 
<h2><a id="tid26">Haeduan</a></h2> <table border="0"> <tr> <td> <img src="images/troops/u26.gif" alt="Haeduan" title="Haeduan" style="border:0px;float: left;" /> </td> <td> <p> 

 <b>Prerequisites:</b> Academy level 15, Stable level 10<br /> The Haeduans are the Gaul&#x0027;s ultimate weapon referring to attack and cavalry defense. Few can match them in these points. But their training and equipment is accordingly very expensive, and with 3 units of crop as supply per hour you should think very carefully, if they will be worth it. </p> <ul> 

<li>Research: 3100 Lumber, 2580 Clay, 5600 Iron, 1180 Crop, Length: 03:45:00</li> 
<li>Velocity: 13 Fields/Hour</li> 
<li>Load capacity: 65 Resources</li> 
<li>Upkeep: 3 Crop per hour</li> 
<li>Length of training: 1:05:00 for stable level 1</li> </ul> </td> </tr> </table> 

 <h2><a id="tid27">Ram</a></h2> <table border="0"> <tr> <td> <img src="images/troops/u27.gif" alt="Rammholz" title="Rammholz" style="border:0px;float: left;" /> </td> <td> <p> 

 <b>Prerequisites:</b> Academy level 10, Workshop level 1<br /> The ram is a heavy support weapon for your infantry and cavalry. It is its task to destroy the enemy walls and, by doing so, to increase your troops chances to overcome the enemy&#x0027;s fortifications. </p> <ul> 

<li>Research: 5800 Lumber, 2320 Clay, 2840 Iron, 610 Crop, Length: 04:40:00</li> 
<li>Velocity: 4 Fields/Hour</li> 
<li>Load capacity: 0 Resources</li> 
<li>Upkeep: 3 Crop per hour</li> 
<li>Length of training: 1:23:20 for workshop level 1</li> </ul> </td> </tr> </table>

 <h2><a id="tid28">Trebuchet</a></h2> <table border="0"> <tr> <td> <img src="images/troops/u28.gif" alt="Trebuchet" title="Trebuchet" style="border:0px;float: left;" /> </td> <td> <p> 
 
 <b>Prerequisites:</b> Academy level 15, Workshop level 10, <br />

 The trebuchet is an excellent distance weapon and it is used to destroy the fields and buildings of enemy villages. But without escorting troops it is almost defenseless, so don&#x0027;t forget to send some of your troops with it. <br /> The further the level of your rally point is, the better your trebuchets&#x0027; accuracy and so are your options to choose the enemy buildings that you want to attack with your catapults. With a rally point at level 10 each building -except the cranny- can be chosen as a target. <br />
 With rally point level 20 it is possible to target two buildings in one attack (<em>Hint: T3 only</em>). </p> <ul> 
<li>Research: 5860 Lumber, 5900 Clay, 5240 Iron, 700 Crop, Length: 08:00:00</li> 
<li>Velocity: 3 Fields/Hour</li> 

<li>Load capacity: 0 Resources</li> 
<li>Upkeep: 6 Crop per hour</li> 
<li>Length of training: 2:30:00 for workshop level 1</li> </ul> </td> </tr> </table>

 <h2><a id="tid29">Chieftain</a></h2> <table border="0"> <tr> <td> <img src="images/troops/u29.gif" alt="Chieftain" title="Chieftain" style="border:0px;float: left;" /> </td> <td> <p>

 <b>Prerequisites:</b> Academy level 20, Rally point level 10, free expansion slot in Residence / Palace<br /> Each tribe has an ancient and experienced fighter whose presence and speeches are able to convince the population of enemy villages to join his tribe. The more often he speaks in front of the walls of an enemy village, the more its loyalty sinks, until it joins the chieftain&#x0027;s tribe. </p> <ul> 
<li>Research: 15880 Lumber, 22900 Clay, 25200 Iron, 22600 Crop, Length: 06:47:55</li> 
<li>Velocity: 5 Fields/Hour</li> 
<li>Load capacity: 0 Resources</li> 
<li>Upkeep: 4 Crop per hour</li> 

<li>Length of training: 25:11:40 for Residence or Palace level 1</li> </ul> </td> </tr> </table>

 <h2><a id="tid30">Settler</a></h2> <table border="0"> <tr> <td> <img src="images/troops/u30.gif" alt="Settler" title="Settler" style="border:0px;float: left;" /> </td> <td> <p> 

 <b>Prerequisites:</b> free expansion slot in Residence / Palace<br /> Settlers are brave and daring citizens who move out of the village after a long training to found a new village in your honour. As the journey and the founding of the new village are very difficult, three settlers are bound stick together. Meanwhile they need a basis of 750 units per resource. </p> <ul> 

<li>Research: 0 Lumber, 0 Clay, 0 Iron, 0 Crop, Length: /</li> 
<li>Velocity: 5 Fields/Hour</li> 
<li>Load capacity: 3000 (T2: 1600) Resources</li> 
<li>Upkeep: 1 Crop per hour</li> 
<li>Length of training: 7:28:20 for Residence or Palace level 1</li> </ul> </td> </tr> </table> 

 <h2><a id="tid99">Trap</a></h2> <table border="0"> <tr> <td> <img src="images/misc/fragezeichen.gif" alt="Trap" title="Trap" style="border:0px;float: left;" /> </td> <td> <p> <b>Prerequisites:</b> Trapper level 1<br />

 Traps are used by the Gauls to defend their villages and can only be build by this tribe. When an enemy host tries to plunder a gaulish village and traps have been placed one enemy soldier will be captured per trap.<br /><br />These troops cannot be freed with a raid. When troops get freed with a successful normal attack, 1/3 of the traps can be repaired. If the owner of the traps releases the captives, then 1/2 of the traps can be repaired. </p> <ul> <li>Research: 0 Lumber, 0 Clay, 0 Iron, 0 Crop, Length: /</li> <li>Velocity: / Fields/Hour</li> <li>Load capacity: /</li> <li>Upkeep: 0 Crop per hour</li> <li>Length of training: 0:27:40 for Trapper level 1</li> </ul> </td> </tr> </table>	
		</div>

		<table id="footer" cellpadding="2" cellspacing="0">
			<tr>
				<td>
					<form action="" method="post">
						<div>
							<span>Change Menu:</span>
							<select name="changeDesign" size="1" onchange="this.form.submit()">
								<option value="1" >left side</option>

								<option value="2" >right side</option>
								<option value="3" selected="selected">top</option>
							</select>
						</div>
					</form>
				</td>
				<td><a class="link" href="index.php?type=contact&amp;mod=1000&amp;pt=&amp;pm=420">report a mistake</a></td>

				<td></td>
				<td>© 2004 - 2007 Travian Games GmbH</td>
				<td><a class="link" href="#flagbox">top</a></td>
			</tr>
		</table>
	</div>
</body>
</html>
