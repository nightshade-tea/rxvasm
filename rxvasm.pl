#!/usr/bin/perl

use strict;
use warnings;

# TODO: array of imports, iterate requiring

require './rxvdef.pl' or die "Failed to load rxvdef.pl: $@ $!";
require './rxvencode.pl' or die "Failed to load rxvencode.pl: $@ $!";

# reads from a file handle, strips comments, excess whitespace and empty lines,
# then returns a reference to an array of the resulting program lines
sub read_program {
    my ($file) = @_;

    my @program;

    while (<$file>) {
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
    my ($line) = @_;

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
    my ($program) = @_;

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

close $in;

my ($instructions, $label) = extract_labels($program);

my @binary;

foreach (@$instructions) {
    if (/^([a-z]{2,4})/) {
        push @binary, rxvencode::encode_r($_) if $rxvdef::instruction{$1}{type} eq 'r';
        push @binary, rxvencode::encode_i($_, $label, scalar @binary)
            if $rxvdef::instruction{$1}{type} eq 'i';
        next;
    }

    push @binary, @{rxvencode::encode_dir($_)} if (/^\.\w+/);
}

open my $out, '>:raw', $ARGV[1] or die "Failed to open $ARGV[1]: $!";
print $out pack 'C*', @binary;
close $out;

# debug
#print "\@instructions:\n";
#print "$_\n" foreach (@$instructions);

#print "\n\%label:\n";
#print "label=$_ addr=$label->{$_}\n" foreach (sort keys %$label);

#print "\n\@binary:\n";
#printf "%08b\n", $_ foreach (@binary);
