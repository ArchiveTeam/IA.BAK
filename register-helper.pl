#!/usr/bin/perl
use warnings;
use strict;
use CGI;

my ($shard, $uuid, $email, $pubkey) = @ARGV;
$pubkey=~s/+/_/g;
@ARGV=();

my $q=CGI->new;
$q->param("shard", $shard);
$q->param("uuid", $uuid);
$q->param("email", $email);
$q->param("pubkey", $pubkey);
my $url=$q->self_url;
$url=~s!^http://localhost!http://iabak.archiveteam.org/cgi-bin/register.cgi!;
print "$url\n";
