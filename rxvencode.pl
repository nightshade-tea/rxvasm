# rxvencode.pl - instruction and directive encoding subroutines

package rxvencode;

# encodes an r-format instruction string and returns the machine code byte
sub encode_r {
    my ($instr) = @_;

    my ($op, $ra, $rb) = $instr =~ /^([a-z]+)\s+r([0-3]),\s+r([0-3])/;
    my $byte = ($rxvdef::instructions{$op}{opcode} << 4) | ($ra << 2) | $rb;

    return $byte;
}

# encodes an i-format instruction string and returns the machine code byte. a
# label mapping and current address need to be passed as parameters
sub encode_i {
    my ($instr, $label, $addr) = @_;

    my ($op, $imm) = $instr =~ /^([a-z]+)\s+(-?\w+)/;

    if (defined $label->{$imm}) {
        $imm = $label->{$imm} - $addr; # jumps are relative
    }

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
        my @bytes = map { $_ & 0xff } @ops;

        return \@bytes;
    }

    elsif ($rxvdef::directives{$dir}{type} eq 'space') {
        my ($size) = $line =~ /^\.space\s+(\w+)/;
        my @bytes = (0) x $size;

        return \@bytes;
    }
}

1;
