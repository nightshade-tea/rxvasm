# rxvencode.pl - instruction and directive encoding subroutines

package rxvencode;

use strict;
use warnings;
use Scalar::Util;

# encodes an r-format instruction string and returns the machine code byte
sub encode_r {
    my ($instr) = @_;

    my ($op, $ra, $rb) = $instr =~ /^([a-z]+)\s+r([0-3]),\s+r([0-3])$/;

    # fail fast if $instr isn't a valid r-format instruction
    die "fatal error: invalid r-format instruction '$instr'\n"
        unless defined $op;

    my $byte = ($rxvdef::instructions{$op}{opcode} << 4) | ($ra << 2) | $rb;

    return $byte;
}

# encodes an i-format instruction string and returns the machine code byte. a
# label mapping and current address need to be passed as parameters
sub encode_i {
    my ($instr, $label, $addr) = @_;

    my ($op, $imm) = $instr =~ /^([a-z]+)\s+(-?\w+)$/;

    # fail fast if $instr isn't a valid i-format instruction
    die "fatal error: invalid i-format instruction '$instr'\n"
        unless defined $op;

    $imm = $label->{$imm} - $addr if defined $label->{$imm};

    die "fatal error: invalid immediate '$imm' in '$instr'\n"
        unless Scalar::Util::looks_like_number($imm);

    die "fatal error: immediate '$imm' outside of range [-8..7] in '$instr'\n"
        unless ($imm >= -8 && $imm <= 7);

    $imm &= 0xf; # mask to 4 bits

    my $byte = ($rxvdef::instructions{$op}{opcode} << 4) | $imm;

    return $byte;
}

# encodes a directive and returns an arrayref to @bytes
sub encode_dir {
    my ($line) = @_;

    my ($dir) = $line =~ /^\.(\w+)/ or return;

    if ($rxvdef::directives{$dir}{type} eq 'bits') {
        my @ops = split /\s+/, $line;
        shift @ops; # drop .bitsx

        die "fatal error: directive '$dir' requires at least one operand in "
            . "'$line'\n" unless @ops;

        my @bytes = map {

            # ensure it is an integer
            die "fatal error: invalid operand '$_' in '$line'\n"
                unless Scalar::Util::looks_like_number($_) && /^-?\w+$/;

            die "fatal error: operand '$_' exceeds 8 bits in '$line'\n"
                unless ($_ >= -128 && $_ <= 255);

            $_ & 0xff;
        } @ops;

        return \@bytes;
    }

    elsif ($rxvdef::directives{$dir}{type} eq 'space') {
        my ($size) = $line =~ /^\.space\s+(\w+)$/;

        die "fatal error: directive '$dir' requires exactly one operand in "
            . "'$line'\n" unless defined $size;


        die "fatal error: invalid operand '$size' in '$line'\n"
            unless Scalar::Util::looks_like_number($size)
                   && $size =~ /^\w+$/
                   && $size > 0;

        my @bytes = (0) x $size;

        return \@bytes;
    }
}

1;
