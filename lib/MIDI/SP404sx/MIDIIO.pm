package MIDI::SP404sx::MIDIIO;
use strict;
use warnings FATAL => 'all';
use Data::Dumper;
use MIDI;
use MIDI::SP404sx::Note;
use MIDI::SP404sx::Pattern;
use Log::Log4perl qw(:easy);

my $type     = 0;
my $dtime    = 1;
my $channel  = 2;
my $note     = 3;
my $velocity = 4;

sub read_pattern {
    my $class = shift;
    my $file = shift;
    my $opus = MIDI::Opus->new({ from_file => $file });
    #print Dumper($opus);
    return decode_events($opus);
}

sub decode_events {
    my $opus = shift;
    my $pattern = MIDI::SP404sx::Pattern->new;
    for my $track ( $opus->tracks ) {
        my %seen;
        my $position = 0;
        EVENT: for my $e ( $track->events ) {
            next EVENT unless $e->[$type] =~ /(note|set_tempo)/;
            if ( $e->[$type] eq 'set_tempo' ) {
                next EVENT;
            }
            $position += $e->[$dtime];
            my $t  = $position / $opus->ticks;
            my $n  = $e->[$note];
            my $c  = $e->[$channel];
            my $id = "${n},${c}";

            # process note on event
            if ( $e->[$type] eq 'note_on' ) {
                $seen{$id} = MIDI::SP404sx::Note->new(
                    pitch    => $n,
                    channel  => $c,
                    position => $t,
                    pattern  => $pattern,
                    velocity => $e->[$velocity],
                );
            }

            # process note off event
            if ( $e->[$type] eq 'note_off' ) {
                if ( my $note_obj = $seen{$id} ) {
                    $note_obj->nlength( $t - $note_obj->position );
                }
                else {
                    die "Received note off without note on";
                }
            }
        }
    }
    return $pattern;
}

sub write_pattern {
    my $class = shift;
    my ( $pattern, $file ) = @_;
    my $ppqn = $MIDI::SP404sx::Constants::PPQ;
    my $opus = MIDI::Opus->new({ format => 1, ticks => $ppqn });
    my @tracks;
    for my $c ( sort { $a <=> $b } keys %{{ map { $_->channel => 1 } $pattern->notes }}) {
        my ( $track, $position, @offs ) = ( MIDI::Track->new, 0 );
        my @events = ( [ 'track_name', 0, scalar(@tracks) == 0 ? 'Base channel' : 'Upper channel' ] );
        for my $n ( sort { $a->position <=> $b->position } grep { $_->channel == $c } $pattern->notes ) {

            # resolve any dangling note-off events
            my @noffs;
            for my $o ( sort { $a->{position} <=> $b->{position} } @offs ) {
                if ( $o->{position} <= $n->position ) {
                    $o->{event}->[$dtime] = int( ( $o->{position} - $position ) * $ppqn );
                    $position = $o->{position};
                    push @events, $o->{event};
                }
                else {
                    push @noffs, $o;
                }
            }
            @offs = @noffs;

            # create and insert note on
            my $delta_t = int( ( $n->position - $position ) * $ppqn );
            my @on = ( 'note_on', $delta_t, $n->channel, $n->pitch, $n->velocity );
            push @events, \@on;

            # queue dangling note-off event
            my @off = @on;
            $off[$type] = 'note_off';
            push @offs, { position => $n->position + $n->nlength, event => \@off };
        }
        $track->events(@events);
        push @tracks, $track;
    }
    $opus->tracks(@tracks);
    #print Dumper($opus);
    $opus->write_to_file($file);
}

1;