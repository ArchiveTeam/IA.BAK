#!/usr/bin/perl
# emulate linux flock command line utility
#
use warnings;
use strict;
use Fcntl qw(:flock);
use Getopt::Long qw(:config require_order);
use Pod::Usage qw(pod2usage);
# line buffer
$|=1;

my $exclusive = 1;
my $shared = 0;
my $nonblock = 0;
my $command = '';
my $help = '';
GetOptions ("exclusive|x" => \$exclusive,
            "shared|x" => \$shared,
            "nonblock|n" => \$nonblock,
            "help|h|?" => \$help) or pod2usage(2);

my $file = shift;
if (!$command) {
  $command = join(" ", @ARGV);
}

if ($help) {
  pod2usage(0);
}

if (!$file || !$command) {
   pod2usage(3);
}

open(FH, '>', $file) || die($!);
flock(FH,
      ($shared ? LOCK_SH : LOCK_EX) |
      ($nonblock ? LOCK_NB : 0)) or die($!);
system($command);
flock(FH, LOCK_UN);

__END__

=head1 NAME

flock - stuff

=head1 SYNOPSIS

flock [options] [command arguments ...]

 Options:
   --help           full help message
   -x, --exclusive  write lock
   -s, --shared     read lock
   -n, --nonblock   non-blocking

=head1 OPTIONS

=over 8

=item B<-x, --exclusive>

Use an exclusive (write) lock. This is the default.

=item B<-s, --shared>

Use a shared (read) lock

=item B<-n, --nonblock>

Use a non-blocking lock

=back

=head1 DESCRIPTION

B<This program> implements those parts of flock(1) which iabak actually uses.

=cut
