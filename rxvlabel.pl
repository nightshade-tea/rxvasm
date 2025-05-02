# rxvlabel.pl - label mapping subroutines

package rxvlabel;

# given a trimmed and stripped line (no labels or comments), returns the size
# in bytes that the instruction or directive needs to be written to the binary
sub mem_size {
    my ($line) = @_;

    my ($dir) = $line =~ /^\.(\w+)/ or return 1;

    if ($rxvdef::directive{$dir}{type} eq 'bits') {
        my @ops = split /\s+/, $line;
        return (scalar @ops - 1) * $rxvdef::directive{$dir}{bytes_per_op};
    }

    elsif ($rxvdef::directive{$dir}{type} eq 'space') {
        my ($size) = $line =~ /^\.space\s+(\w+)/;
        return $size;
    }

    return 0;
}

# strip labels from \@program and map them to their addresses. returns the
# references to the stripped program and to the labels map
sub extract_labels {
    my ($program) = @_;

    my @instructions;
    my %label;
    my $addr = 0;

    foreach (@$program) {
        $label{$1} = $addr if (s/^(\w+):\s*//);

        unless (/^$/) {
            push @instructions, $_;
            $addr += mem_size($_);
        }
    }

    return (\@instructions, \%label);
}

1;
