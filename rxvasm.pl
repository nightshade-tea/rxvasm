#!/usr/bin/perl

use strict;
use warnings;

# TODO: array of imports, iterate requiring

require './rxvdef.pl' or die "Failed to load rxvdef.pl: $@ $!";
require './rxvencode.pl' or die "Failed to load rxvencode.pl: $@ $!";
require './rxvlabel.pl' or die "Failed to load rxvlabel.pl: $@ $!";

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

die "usage: perl rxvasm.pl <program.s> <out.bin>" if @ARGV != 2;

open my $in, "<", $ARGV[0] or die "Failed to open $ARGV[0]: $!";

my $program = read_program($in);

close $in;

my ($instructions, $label) = rxvlabel::extract_labels($program);

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
