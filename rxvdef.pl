# rxvdef.pl - reduxv architecture definitions

package rxvdef;

our %instr = (
    brzr => {
             opcode => 0b0000,
             type => 'r'
            },
    ji   => {
             opcode => 0b0001,
             type => 'r'
            },
    ld   => {
             opcode => 0b0010,
             type => 'r'
            },
    st   => {
             opcode => 0b0011,
             type => 'r'
            },
    addi => {
             opcode => 0b0100,
             type => 'r'
            },
    not  => {
             opcode => 0b1000,
             type => 'r'
            },
    and  => {
             opcode => 0b1001,
             type => 'r'
            },
    or   => {
             opcode => 0b1010,
             type => 'r'
            },
    xor  => {
             opcode => 0b1011,
             type => 'r'
            },
    add  => {
             opcode => 0b1100,
             type => 'r'
            },
    sub  => {
             opcode => 0b1101,
             type => 'r'
            },
    slr  => {
             opcode => 0b1110,
             type => 'r'
            },
    srr  => {
             opcode => 0b1111,
             type => 'r'
            }
);

1;
