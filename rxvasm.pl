#!/usr/bin/perl

use strict;
use warnings;

require './rxvdef.pl' or die "Failed to load rxvdef.pl: $@ $!";

# parses an r-format instruction string and returns (op, ra, rb)
sub parse_r {
    my $instr = shift or return;
    my ($op, $ra, $rb) = $instr =~ /([a-z]{2,4})\s+(r[0-3]),\s+(r[0-3])/;

    return ($op, $ra, $rb);
}

# parses an i-format instruction string and returns (op, imm)
sub parse_i {
    my $instr = shift or return;
    my ($op, $imm) = $instr =~ /([a-z]{2,4})\s+(-?\w+)/;

    return ($op, $imm);
}

# given a trimmed and stripped line (no labels or comments), returns the size
# in bytes that the instruction or directive needs to be written to the binary
sub mem_size {
    my $line = shift or return;
    my ($dir) = $line =~ /^\.(\w+)/ or return 1;

    if ($rxvdef::directive{$dir}{type} eq 'bits') {
        my @ops = split /\s+/, $line;
        return (scalar @ops - 1) * $rxvdef::directive{$dir}{bytes_per_op};
    }

    elsif ($rxvdef::directive{$dir}{type} eq 'space') {
        my ($size) = $line =~ /^\.space\s+(\w+)/;
        return $size;
    }

    return 0;
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

my @instructions;
my %label;
my $addr = 0;

foreach (@program) {
    my $l;

    if (s/^(\w+):\s*//) {
        $l = $1;
        $label{$l} = $addr;
    }

    unless (/^$/) {
        push @instructions, $_;
        $addr++;
    }
}

my @binary;

print "$_\n" foreach (@instructions);

foreach (sort keys %label) {
    print "label=";
    print;
    print " addr=";
    print $label{$_};
    print "\n";
}
