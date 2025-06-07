# rxvdef.pl - reduxv architecture definitions

package rxvdef;

use strict;
use warnings;

# if you add more instructions, make sure that their names can be matched by
# this regex pattern: /[a-z]+/

# instruction set definition
# keys are mnemonics, values define type and opcode
our %instructions = (
    brzr => {
             type => 'r',
             opcode => 0b0000
            },
    brzi => {
             type => 'i',
             opcode => 0b0001
            },
    jr   => {
             type => 'r',
             opcode => 0b0010
            },
    ji   => {
             type => 'i',
             opcode => 0b0011
            },
    ld   => {
             type => 'r',
             opcode => 0b0100
            },
    st   => {
             type => 'r',
             opcode => 0b0101
            },
    movh => {
             type => 'i',
             opcode => 0b0110
            },
    movl => {
             type => 'i',
             opcode => 0b0111
            },
    add  => {
             type => 'r',
             opcode => 0b1000
            },
    sub  => {
             type => 'r',
             opcode => 0b1001
            },
    and  => {
             type => 'r',
             opcode => 0b1010
            },
    or   => {
             type => 'r',
             opcode => 0b1011
            },
    not  => {
             type => 'r',
             opcode => 0b1100
            },
    slr  => {
             type => 'r',
             opcode => 0b1101
            },
    srr  => {
             type => 'r',
             opcode => 0b1110
            },
    nop  => {
             type => 'n',
             opcode => 0b1111
            }
);

# assembler directive definitions
# keys are directive names, values define behavior
our %directives = (
    bits8   => {
                type => 'bits',     # embeds values into memory
                bytes_per_op => 1   # size allocated for each operand
               },
#   bits16  => {
#               type => 'bits',
#               bytes_per_op => 2
#              },
#   bits32  => {
#               type => 'bits',
#               bytes_per_op => 4
#              },
#   bits64  => {
#               type => 'bits',
#               bytes_per_op => 8
#              },
    space   => {
                type => 'space'     # allocates zeroed space
               },
#   include => {
#               type => 'include'
#              }
);

1;
