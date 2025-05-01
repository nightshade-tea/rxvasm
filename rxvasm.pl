#!/usr/bin/perl

use strict;
use warnings;

require './rxvdef.pl' or die "Failed to load rxvdef.pl: $@ $!";

# parses an r-format instruction string and returns (op, ra, rb)
sub parse_r {
    my $instr = shift;
    my ($op, $ra, $rb) = $instr =~ /([a-z]{2,4})\s+(r[0-3]),\s+(r[0-3])/;

    return ($op, $ra, $rb);
}

# parses an i-format instruction string and returns (op, imm)
sub parse_i {
    my $instr = shift;
    my ($op, $imm) = $instr =~ /([a-z]{2,4})\s+(-?\w+)/;

    return ($op, $imm);
}

die "usage: perl rxvasm.pl <program.s> <out.bin>" if @ARGV != 2;

open my $in, "<", $ARGV[0] or die "Failed to open $ARGV[0]: $!";

my @program;

while (<$in>) {
    chomp;
    s/^\s+|\s+$//g; # trim whitespaces
    s/\s*;.*$//; # strip comments
    next if /^$/; # skip empty lines
    push @program, $_;
}

my @instruction;
my %label;
my $addr = 0;

foreach (@program) {
    my $l;

    if (s/^(\w+):\s*//) {
        $l = $1;
        $label{$l} = $addr;
    }

    unless (/^$/) {
        push @instruction, $_;
        $addr++;
    }
}

my @binary;

print "$_\n" foreach (@instruction);

foreach (sort keys %label) {
    print "label=";
    print;
    print " addr=";
    print $label{$_};
    print "\n";
}
