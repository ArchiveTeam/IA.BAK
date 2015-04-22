#!/usr/bin/perl
use warnings;
use strict;
use CGI;

$ENV{REQUEST_METHOD}="GET";
$ENV{QUERY_STRING}=shift @ARGV;

my $q = CGI->new;
my $email = $q->param("email");
my $shard = $q->param("shard");
my $pubkey = $q->param("pubkey");
if ($shard !~ /^SHARD\d+$/) {
	oops("bad SHARD $shard");
}
$pubkey=~s/_/+/g; # + is space in CGI..
my ($sanitized_pubkey)=$pubkey=~/^(ssh-rsa [^\s]+)/;
my ($sanitized_email)=$email=~/^([^\s]+)/;
if ($sanitized_pubkey eq "" || $sanitized_email eq "") {
	oops("bad inputs");
}

chdir("/home/registrar/users/") || oops("chdir: $!");
system("git pull");
if (! -d $shard) {
	mkdir("$shard") || oops("mkdir: $!");
}
open (OUT, ">>$shard/pubkeys") || oops("open: $!");
print OUT "$sanitized_pubkey $sanitized_email\n";
close OUT;
system("git add $shard/pubkeys; git -c user.email=registrar\@iabak -c user.name=registrar commit -m registration; git push origin master");
print "** REGISTRATION SUCCEEDED **";
exit 0;

sub oops {
	my $msg=shift;
	print "REGISRATION FAILED: $msg\n";
	print "";
	print "Please contact the #internetarchive.bak IRC channel on irc.efnet.org for support!";
	exit 1;
}
