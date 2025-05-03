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

# parse an i-format instruction into lexical components
sub parse_i {
    my ($instr, $label_map, $addr) = @_;

    # extract mnemonic and immediate
    my ($op, $imm) = $instr =~ /^([a-z]+)\s+(-?\w+)$/;

    # fail if format is wrong
    die "fatal error: invalid i-format instruction '$instr'\n"
        unless defined $op;

    # resolve label to offset
    $imm = $label_map->{$imm} - $addr if defined $label_map->{$imm};

    # ensure numeric immediate
    die "fatal error: invalid immediate '$imm' in '$instr'\n"
        unless Scalar::Util::looks_like_number($imm);

    # ensure within signed 4-bit range
    die "fatal error: immediate '$imm' outside of range [-8..7] in '$instr'\n"
        unless ($imm >= -8 && $imm <= 7);

    return ($op, $imm);
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
