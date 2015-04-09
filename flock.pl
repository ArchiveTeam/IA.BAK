#!/usr/bin/perl
# emulate linux flock command line utility
#
use warnings;
use strict;
use Fcntl qw(:flock);
# line buffer
$|=1;

my $file = shift;
my $cmd = join(" ", @ARGV);

if(!$file || !$cmd) {
   die("usage: $0 <file> <command> [ <command args>... ]\n");
}

open(FH, '>', $file) || die($!);
flock(FH, LOCK_EX | LOCK_NB) || die($!);
system($cmd);
flock(FH, LOCK_UN);
