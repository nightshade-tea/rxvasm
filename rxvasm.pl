#!/usr/bin/perl

use strict;
use warnings;

# import required modules for definitions, encoding, and label extraction
require $_ foreach ('./rxvdef.pl', './rxvencode.pl', './rxvlabel.pl');

# strips comments, excess whitespace and empty lines, then returns an arrayref
# to the resulting program lines
sub read_program {
    # args:
    # $file is a file handle to a program
    my ($file) = @_;
    my @program;

    while (<$file>) {
        chomp;              # remove trailing newline
        s/^\s+|\s+$//g;     # trim leading and trailing whitespace
        s/\s*;.*$//;        # remove comments
        next if /^$/;       # skip empty lines
        push @program, $_;
    }

    # return:
    # an arrayref to @program, which is an array of instructions, directives
    # and labels
    return \@program;
}

# encodes a stripped program (no labels) into binary form
sub assemble_binary {
    # args:
    # $stripped_program is an arrayref to a program stripped of labels
    # $label_map is a hashref mapping label names to addresses
    my ($stripped_program, $label_map) = @_;
    my @binary;

    foreach (@$stripped_program) {

        # encode instructions
        if (/^([a-z]{2,4})/) {

            # type 'r'
            push @binary, rxvencode::encode_r($_)
                if $rxvdef::instruction{$1}{type} eq 'r';

            # type 'i'
            push @binary, rxvencode::encode_i($_, $label_map, scalar @binary)
                if $rxvdef::instruction{$1}{type} eq 'i';

            next;
        }

        # encode directives
        push @binary, @{rxvencode::encode_dir($_)} if (/^\.\w+/);
    }

    # return:
    # an arrayref to @binary, an array of bytes (machine code)
    return \@binary;
}

# ensure rxvasm has been called with 2 arguments, otherwise print an usage
# message
die "usage: perl rxvasm.pl <program.s> <out.bin>\n" if @ARGV != 2;

# open and read the input file into $program
open my $in, "<", $ARGV[0] or die "Failed to open $ARGV[0]: $!";
my $program = read_program($in);
close $in;

# first pass: strip and map labels
my ($stripped_program, $label_map) = rxvlabel::extract_labels($program);

# second pass: parse, encode and assemble the binary
my $binary = assemble_binary($stripped_program, $label_map);

# write the binary to the output file
open my $out, '>:raw', $ARGV[1] or die "Failed to open $ARGV[1]: $!";
print $out pack 'C*', @$binary;
close $out;
