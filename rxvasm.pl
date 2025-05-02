#!/usr/bin/perl

use strict;
use warnings;

require './rxvdef.pl' or die "Failed to load rxvdef.pl: $@ $!";

# encodes an r-format instruction string and returns the machine code byte
sub encode_r {
    my $instr = shift or return;

    my ($op, $ra, $rb) = $instr =~ /([a-z]{2,4})\s+r([0-3]),\s+r([0-3])/;
    my $byte = ($rxvdef::instruction{$op} << 4) | ($ra << 2) | $rb;

    return $byte;
}

# encodes an i-format instruction string and returns the machine code byte. the
# label mapping and current address need to be passed as parameters
sub encode_i {
    my $instr = shift or return;
    my $label = shift or return;
    my $addr = shift or return;

    my ($op, $imm) = $instr =~ /([a-z]{2,4})\s+(-?\w+)/;

    if (defined $label->{$imm}) {
        $imm = $label->{$imm} - $addr; # jumps are relative
    }

    else {
        $imm += 0;
    }

    $imm &= 0xf; # mask to 4 bits

    my $byte = ($rxvdef::instruction{$op} << 4) | $imm;

    return $byte;
}

# TODO: encode_dir

# reads from a file handle, strips comments, excess whitespace and empty lines,
# then returns a reference to an array of the resulting program lines
sub read_program {
    my $in = shift or return;
    my @program;

    while (<$in>) {
        chomp;
        s/^\s+|\s+$//g; # trim whitespaces
        s/\s*;.*$//; # strip comments
        next if /^$/; # skip empty lines
        push @program, $_;
    }

    return \@program;
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

# strip labels from \@program and map them to their addresses. returns the
# references to the stripped program and to the labels map
sub extract_labels {
    my $program = shift or return;
    my @instructions;
    my %label;
    my $addr = 0;

    foreach (@$program) {
        $label{$1} = $addr if (s/^(\w+):\s*//);

        unless (/^$/) {
            push @instructions, $_;
            $addr += mem_size($_);
        }
    }

    return (\@instructions, \%label);
}

die "usage: perl rxvasm.pl <program.s> <out.bin>" if @ARGV != 2;

open my $in, "<", $ARGV[0] or die "Failed to open $ARGV[0]: $!";

my $program = read_program($in);
my ($instructions, $label) = extract_labels($program);

my @binary;

# TODO ...

# debug
print "\@instructions:\n";
print "$_\n" foreach (@$instructions);

print "\n\%label:\n";
print "label=$_ addr=$label->{$_}\n" foreach (sort keys %$label);

close $in;
