package MIDI::SP404sx::MIDIIO;
use strict;
use warnings FATAL => 'all';
use Data::Dumper;
use MIDI;
use MIDI::SP404sx::Note;
use MIDI::SP404sx::Pattern;
use Log::Log4perl qw(:easy);

Log::Log4perl->easy_init($DEBUG);

my $type     = 0;
my $dtime    = 1;
my $channel  = 2;
my $note     = 3;
my $velocity = 4;

sub read_midi {
    my $file = shift;
    my $opus = MIDI::Opus->new({ from_file => $file });
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
            DEBUG Dumper($e);
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

1;