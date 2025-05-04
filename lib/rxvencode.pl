# rxvencode.pl - instruction and directive encoding subroutines

package rxvencode;

use strict;
use warnings;

require 'rxvdef.pl';

# encode an r-type instruction into a byte
sub encode_r {
    my ($op, $ra, $rb) = @_;

    # opcode[7:4] | ra[3:2] | rb[1:0]
    my $byte = ($rxvdef::instructions{$op}{opcode} << 4) | ($ra << 2) | $rb;

    return $byte;
}

# encode an i-type instruction into a byte
sub encode_i {
    my ($op, $imm) = @_;

    # mask to 4 bits
    $imm &= 0xf;

    # opcode[7:4] | imm[3:0]
    my $byte = ($rxvdef::instructions{$op}{opcode} << 4) | $imm;

    return $byte;
}

# encode a bits type directive into bytes
sub encode_bits {
    my ($dir, $ops) = @_;

    # mask each operand to 8 bits
    my @bytes = map $_ & 0xff, @$ops;

    return \@bytes;
}

# encode a space type directive into zeroed bytes
sub encode_space {
    my ($size) = @_;

    my @bytes = (0) x $size;

    return \@bytes;
}

1;
