# rxvdef.pl - reduxv architecture definitions

package rxvdef;

our %instruction = (
    brzr => {
             type => 'r',
             opcode => 0b0000
            },
    ji   => {
             type => 'i',
             opcode => 0b0001
            },
    ld   => {
             type => 'r',
             opcode => 0b0010
            },
    st   => {
             type => 'r',
             opcode => 0b0011
            },
    addi => {
             type => 'i',
             opcode => 0b0100
            },
    not  => {
             type => 'r',
             opcode => 0b1000
            },
    and  => {
             type => 'r',
             opcode => 0b1001
            },
    or   => {
             type => 'r',
             opcode => 0b1010
            },
    xor  => {
             type => 'r',
             opcode => 0b1011
            },
    add  => {
             type => 'r',
             opcode => 0b1100
            },
    sub  => {
             type => 'r',
             opcode => 0b1101
            },
    slr  => {
             type => 'r',
             opcode => 0b1110
            },
    srr  => {
             type => 'r',
             opcode => 0b1111
            }
);

our %directive = (
    bits8   => {
                type => 'bits',
                bytes_per_op => 1
               },
    bits16  => {
                type => 'bits',
                bytes_per_op => 2
               },
    bits32  => {
                type => 'bits',
                bytes_per_op => 4
               },
    bits64  => {
                type => 'bits',
                bytes_per_op => 8
               },
    space   => {
                type => 'space'
               },
    include => {
                type => 'include'
               }
);

1;
