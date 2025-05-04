#!/usr/bin/perl

# rxvasm.pl - reduxv assembler

use v5.32;
use strict;
use warnings;

BEGIN {
    my ($root) = $0 =~ /^(.*)rxvasm.pl$/;
    push @INC, $root . 'lib';
}

require 'rxvassemble.pl';
require 'rxvlabel.pl';

# ensure rxvasm has been called with 2 arguments, otherwise print an usage
# message
die "usage: perl rxvasm.pl <program.s> <out.bin>\n" if @ARGV != 2;

# open and read the input file into $program
open my $in, "<", $ARGV[0] or die "Failed to open '$ARGV[0]': $!\n";
my $program = rxvassemble::read_program($in);
close $in;

# first pass: strip and map labels
my ($stripped_program, $label_map) = rxvlabel::extract_labels($program);

# second pass: parse, encode and assemble the binary
my $binary = rxvassemble::assemble_binary($stripped_program, $label_map);

# write the binary to the output file
open my $out, '>:raw', $ARGV[1] or die "Failed to open '$ARGV[1]': $!\n";
print $out pack 'C*', @$binary;
close $out;
