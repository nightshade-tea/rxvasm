# rxvassemble.pl - reduxv assembler subroutines

package rxvassemble;

use strict;
use warnings;

require 'rxvdef.pl';
require 'rxvparse.pl';
require 'rxvencode.pl';

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
    # and possibly labels
    return \@program;
}

# parses and encodes an instruction into binary form
sub assemble_instruction {
    my ($op, $line, $label_map, $addr) = @_;

    # check if instruction is defined in rxvdef
    die "fatal error: unknown instruction '$op' in '$line'\n"
        unless defined $rxvdef::instructions{$op};

    # type 'r'
    if ($rxvdef::instructions{$op}{type} eq 'r') {
        my ($op, $ra, $rb) = rxvparse::parse_r($line);
        return rxvencode::encode_r($op, $ra, $rb);
    }

    # type 'i'
    elsif ($rxvdef::instructions{$op}{type} eq 'i') {
        my ($op, $imm) = rxvparse::parse_i($line, $label_map, $addr);
        return rxvencode::encode_i($op, $imm);
    }

    # type 'n'
    elsif ($rxvdef::instructions{$op}{type} eq 'n') {
        my $op = rxvparse::parse_n($line);
        return rxvencode::encode_n($op);
    }

    # unhandled type
    die "fatal error: unhandled instruction type for '$op' in '$line'\n";
}

# parses and encodes a directive into binary form
sub assemble_directive {
    my ($dir, $line) = @_;

    # check if directive is defined in rxvdef
    die "fatal error: unknown directive '$dir' in '$line'\n"
        unless defined $rxvdef::directives{$dir};

    # type 'bits'
    if ($rxvdef::directives{$dir}{type} eq 'bits') {
        my ($dir, $ops) = rxvparse::parse_bits($line);
        return rxvencode::encode_bits($dir, $ops);
    }

    # type 'space'
    elsif ($rxvdef::directives{$dir}{type} eq 'space') {
        my $size = rxvparse::parse_space($line);
        return rxvencode::encode_space($size);
    }

    # unhandled type
    die "fatal error: unhandled directive type for '$dir' in '$line'\n";
}

# encodes a stripped program (no labels) into binary form
sub assemble_binary {
    # args:
    # $stripped_program is an arrayref to a program stripped of labels
    # $label_map is a hashref mapping label names to addresses
    my ($stripped_program, $label_map) = @_;
    my @binary;

    foreach (@$stripped_program) {

        # parse and encode instructions
        if (/^([a-z]+)/) {
            push @binary, assemble_instruction($1, $_, $label_map,
                                               scalar @binary);
            next;
        }

        # parse and encode directives
        if (/^\.(\w+)/) {
            push @binary, @{assemble_directive($1, $_)};
            next;
        }

        # $_ is neither an instruction nor a directive
        die "fatal error: invalid construct '$_'\n";
    }

    # return:
    # an arrayref to @binary, an array of bytes (machine code)
    return \@binary;
}

1;
