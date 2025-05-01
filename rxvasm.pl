use strict;
use warnings;

require './rxvdef.pl' or die "failed to load rxvdef.pl: $@ $!";

# parses an r-format instruction string and returns (op, ra, rb)
sub parse_r {
    my $instr = shift or die;

    return ($instr =~ /([a-z]{2,4})\s+(r[0-3]),\s+(r[0-3])/
        or die "invalid instruction format: $instr\n");
}

# parses an i-format instruction string and returns (op, imm)
sub parse_i {
    my $instr = shift or die;

    return ($instr =~ /([a-z]{2,4})\s+(-?\w+)/
        or die "invalid instruction format: $instr\n");
}
