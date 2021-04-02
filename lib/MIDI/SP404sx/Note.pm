package MIDI::SP404sx::Note;
use strict;
use warnings;
use MIDI::SP404sx::Constants;
use base 'MIDI::SP404sx';

sub velocity {
    my $self = shift;
    if ( @_ ) {
        my $val = int(shift);
        if ( $val >= 0 && $val <= $MIDI::SP404sx::Constants::max_velocity ) {
            $self->{velocity} = $val;
        }
        else {
            die $val;
        }
    }
    return $self->{velocity};
}

sub nlength {
    my $self = shift;
    if ( @_ ) {
        my $val = int(shift);

        # XXX compute allowable max length to check, use pattern object
        if ( $val >= 0 ) {
            $self->{nlength} = $val;
        }
        else {
            die $val;
        }
    }
    return $self->{nlength};
}

sub pattern {
    my $self = shift;
    if ( @_ ) {
        my $val = shift;
        if ( UNIVERSAL::isa( $val, 'MIDI::SP404sx::Pattern') ) {
            $self->{pattern} = $val;
        }
        else {
            die $val;
        }
    }
    return $self->{pattern};
}

sub position {
    my $self = shift;
    if ( @_ ) {
        my $val = shift;

        # XXX compute allowable position, use pattern object
        if ( $val >= 0 ) {
            $self->{position} = $val;
        }
        else {
            die $val;
        }
    }
    return $self->{position};
}

sub pitch {
    my $self = shift;
    if ( @_ ) {
        my $val = int(shift);
        if ( $val >= 0 && $val <= $MIDI::SP404sx::Constants::max_note ) {
            $self->{pitch} = $val;
        }
        else {
            die $val;
        }
    }
    return $self->{pitch};
}

sub channel {
    my $self = shift;
    if ( @_ ) {
        my $val = int(shift);
        if ( $val >= 0 && $val <= $MIDI::SP404sx::Constants::max_channel ) {
            $self->{channel} = $val;
        }
        else {
            die $val;
        }
        return $self->{channel};
    }
}

1;
