#!/usr/bin/perl
use Digest::SHA;
use warnings;
use strict;

my $IABAK=shift;

my $pagetemplate;
open (IN, "$IABAK/web/clients/page.template") || die "web/client/page.template: $!";
while (<IN>) { $pagetemplate.=$_ }
close IN;

my $shardtemplate;
open (IN, "$IABAK/web/clients/shard.template") || die "web/client/shard.template: $!";
while (<IN>) { $shardtemplate.=$_ }
close IN;

sub grepshard {
	my $ext=shift;
	my $shard=shift;
	my $uuid=shift;
	my $desc=shift;

	my $ret="";
	open (IN, "$shard.$ext");
	while (<IN>) {
		if (/$uuid/) {
			$ret.=$_;
		}
	}
	if (length $ret) {
		$ret="$desc: $ret";
	}
	return $ret;
}

while (<>) {
	chomp;
	my ($email, $rest)=split(' ', $_, 2);
	my @l=split(' ', $rest);

	my $shards="";
	foreach my $sharduuid (@l) {
		my ($shard, $uuid)=split(/:/, $sharduuid, 2);

		my $info=grepshard("leaderboard-raw", $shard, $uuid, "info");
		if (! length $info) {
			$info="This repo is either expired, or was registered but was never used."
		}

		my $t=$shardtemplate;
	
		$t=~s/UUID/$uuid/g;
		my $lcshard=lc($shard);
		$t=~s/LCSHARD/$lcshard/g;
		$t=~s/SHARD/$shard/g;

		$t=~s/WARNINGLEADERBOARD/grepshard("warningleaderboard-raw", $shard, $uuid, "2 week expire warning")/e;
		$t=~s/EXPIRELEADERBOARD/grepshard("expireleaderboard-raw", $shard, $uuid, "1 week expire warning")/e;
		$t=~s/LEADERBOAD/$info/;

		$shards.=$t;
	}

	my $t=$pagetemplate;
	$t=~s/SHARDLIST/$shards/;
	my $clientname=$email;
	$clientname=~s/@.*//;
	$t=~s/CLIENTNAME/$clientname/;

	my $sha=Digest::SHA::sha1_hex($email);

	open (OUT, ">html/client/$sha.html") || die "html/client/$sha.html: $!";
	print OUT $t;
	close OUT;
}
