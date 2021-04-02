package MIDI::SP404sx::Pattern;
use strict;
use warnings;
use MIDI::SP404sx::Constants;
use base 'MIDI::SP404sx';

sub tempo {
    my $self = shift;
    if ( @_ ) {
        my $val = shift;
        if ( $val >= $MIDI::SP404sx::Constants::min_bpm && $val <= $MIDI::SP404sx::Constants::max_bpm ) {
            $self->{tempo} = $val;
        }
        else {
            die $val;
        }
    }
    return $self->{tempo};
}

sub nlength {
    my $self = shift;
    if ( @_ ) {
        my $val = shift;
        if ( $val >= $MIDI::SP404sx::Constants::min_length && $val <= $MIDI::SP404sx::Constants::max_length ) {
            $self->{nlength} = $val;
        }
        else {
            die $val;
        }
    }
    return $self->{nlength};
}

1;
