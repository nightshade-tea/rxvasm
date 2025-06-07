# rxvparse.pl - instruction and directive parsing subroutines

package rxvparse;

use strict;
use warnings;
use Scalar::Util;

# parse an r-format instruction into lexical components
sub parse_r {
    my ($instr) = @_;

    # extract mnemonic and registers
    my ($op, $ra, $rb) = $instr =~ /^([a-z]+)\s+r([0-3]),\s+r([0-3])$/;

    # fail if format is wrong
    die "fatal error: invalid r-format instruction '$instr'\n"
        unless defined $op;

    return ($op, $ra, $rb);
}

# parse an s-format instruction into lexical components
sub parse_s {
    my ($instr) = @_;

    # extract mnemonic and register
    my ($op, $rb) = $instr =~ /^([a-z]+)\s+r([0-3])$/;

    # fail if format is wrong
    die "fatal error: invalid s-format instruction '$instr'\n"
        unless defined $op;

    return ($op, $rb);
}

# parse an i-format instruction into lexical components
sub parse_i {
    my ($instr, $label_map, $addr) = @_;

    # extract mnemonic and immediate
    my ($op, $imm) = $instr =~ /^([a-z]+)\s+(-?\w+)$/;

    # fail if format is wrong
    die "fatal error: invalid i-format instruction '$instr'\n"
        unless defined $op;

    # resolve label to offset
    if (defined $label_map->{$imm}) {
        $imm = $label_map->{$imm} - $addr;

        # fail if offset is out of bounds (signed)
        die "fatal error: jump offset out of range [-8..7] in '$instr' ",
            "(outside of signed 4-bit range)\n"
            unless ($imm >= -8 && $imm <= 7);
    }

    # parse hex and bin
    unless (Scalar::Util::looks_like_number($imm)) {
        if ($imm =~ /^0x[0-9a-fA-F]+$/) {
            $imm = hex $imm;
        }

        elsif ($imm =~ /^0b[01]+$/) {
            $imm = oct $imm;
        }

        else {
            die "fatal error: failed to parse immediate '$imm' in '$instr'\n";
        }
    }

    # fail if outside of 4-bit range
    die "fatal error: immediate '$imm' outside of range [-8..15] in '$instr' ",
        "(outside of 4-bit range)\n"
        unless ($imm >= -8 && $imm <= 15);

    return ($op, $imm);
}

# parse an n-format instruction into lexical components
sub parse_n {
    my ($instr) = @_;

    # extract mnemonic
    my ($op) = $instr =~ /^([a-z]+)$/;

    # fail if format is wrong
    die "fatal error: invalid n-format instruction '$instr'\n"
        unless defined $op;

    return $op;
}

# parse a bits type directive into its name and operands
sub parse_bits {
    my ($line) = @_;

    # strip directive name
    my ($dir) = $line =~ s/^\.(\w+)\s*//;

    # get space separated operands
    my @ops = split /\s+/, $line;

    # ensure operands exist
    die "fatal error: directive '$dir' requires at least one operand in "
        . "'$line'\n" unless @ops;

    # validate each operand
    foreach (@ops) {
        # ensure it is an integer
        die "fatal error: invalid operand '$_' in '$line'\n"
            unless Scalar::Util::looks_like_number($_) && /^-?\w+$/;

        # ensure it fits in 8 bits
        die "fatal error: operand '$_' exceeds 8 bits in '$line'\n"
            unless ($_ >= -128 && $_ <= 255);
    }

    return ($dir, \@ops);
}

# parse a space directive into its size
sub parse_space {
    my ($line) = @_;

    # get size operand
    my ($dir, $size) = $line =~ /^\.(\w+)\s+(\w+)$/;

    # ensure size was matched
    die "fatal error: directive '$dir' requires exactly one operand in "
        . "'$line'\n" unless defined $dir;


    # ensure size is a positive integer
    die "fatal error: invalid operand '$size' in '$line'\n"
        unless Scalar::Util::looks_like_number($size)
               && $size =~ /^\w+$/
               && $size > 0;

    return $size;
}

1;
