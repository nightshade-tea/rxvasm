# rxvlabel.pl - label mapping subroutines

package rxvlabel;

use strict;
use warnings;

# compute size in bytes for a line (instruction or directive)
sub mem_size {
    my ($line) = @_;

    # non-directive lines are assumed to be instructions of size 1 byte
    my ($dir) = $line =~ /^\.(\w+)/ or return 1;

    # bits directive: size = (operand count) x bytes_per_op
    if ($rxvdef::directives{$dir}{type} eq 'bits') {
        my @ops = split /\s+/, $line;
        return (scalar @ops - 1) * $rxvdef::directives{$dir}{bytes_per_op};
    }

    # space directive: operand is size in bytes
    if ($rxvdef::directives{$dir}{type} eq 'space') {
        my ($size) = $line =~ /^\.space\s+(\w+)$/;
        return $size;
    }

    # other directives default to zero
    return 0;
}

# strip labels and build a label to address map
sub extract_labels {
    my ($program) = @_;

    my @stripped_program;
    my %label_map;
    my $addr = 0;

    foreach (@$program) {

        # capture and remove a label recoding its address
        $label_map{$1} = $addr if (s/^(\w+):\s*//);

        # discard empty lines and compute the next address
        unless (/^$/) {
            push @stripped_program, $_;
            $addr += mem_size($_);
        }
    }

    return (\@stripped_program, \%label_map);
}

1;
