use strict;
use warnings;

my %opcode = (
    brzr => 0b0000,
    ji   => 0b0001,
    ld   => 0b0010,
    st   => 0b0011,
    addi => 0b0100,
    not  => 0b1000,
    and  => 0b1001,
    or   => 0b1010,
    xor  => 0b1011,
    add  => 0b1100,
    sub  => 0b1101,
    slr  => 0b1110,
    srr  => 0b1111
);
