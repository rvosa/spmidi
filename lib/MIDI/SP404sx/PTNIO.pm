package MIDI::SP404sx::PTNIO;
use strict;
use warnings;
use Data::Dumper;
use MIDI::SP404sx::Note;
use MIDI::SP404sx::Pattern;
use MIDI::SP404sx::Constants;
use Log::Log4perl qw(:easy);

Log::Log4perl->easy_init($DEBUG);

my $BLOCK_SIZE=1024;

sub read_bin {
    my $file = shift;
    open my $fh, '<', $file or die $!;
    binmode($fh);
    my $buf;
    my $offset = 0;
    my @result;
    my $i = 0;
    while( read( $fh, $buf, $BLOCK_SIZE, $offset * $BLOCK_SIZE ) ){
	    for( split( //, $buf ) ) {
            my $hex = ord( $_ );
		    printf( "0x%02x ", $hex );
            $i++;
            unless ( $i % 8 ) {
                print "\n";
            }
            push @result, $hex;
	    }
	    $offset++;
    }
    close( $fh );
    return @result;
}

sub decode_hex {
    my @hex = @_;
    my @map = (
        \&next_sample,
        \&pad_code,
        \&bank_switch,
        \&noop,
        \&velocity,
        \&noop,
        \&nlength,
    );
    my $i = 0; # iterates over handlers in @map
    my $p = MIDI::SP404sx::Pattern->new( nlength => $hex[-7] );
    my $n = MIDI::SP404sx::Note->new( pattern => $p );
    for my $j ( 0 .. ( $#hex - 16 ) ) {

        # dispatch two byte handler for length, otherwise one byte handler
        if ( $i == 6 ) {
            $map[$i]->( @hex[ $j, $j+1 ], $n );
        }
        elsif ( $i < 6 ) {
            $map[$i]->( $hex[$j], $n );
        }

        # increment index of byte handler or instantiate new round
        if ( $i < 7 ) {
            $i++;
        }
        else {
            $i = 0;
            $n = MIDI::SP404sx::Note->new( pattern => $p );
        }
    }
    return $p;
}

sub next_sample {
    my ( $pos, $n ) = @_;
    DEBUG "next: $pos";

    # Specifies the number of ticks until the next sample in the pattern should be triggered. For samples played
    # simultaneously all but one have a Next Sample value of 0, play the next sample 0 ticks after the current
    # sample. All 4 samples in the example pattern have a Next Note value of 0x60 which is the hex value that
    # represents a quarter bar. 384 / 4 = 96 or 0x60.
    $n->position($pos);
}

# used to translate
sub pad_code {
    my ( $hex_code, $n ) = @_;
    DEBUG "pitch $hex_code";

    # pitch maps to MIDI note nr
    $n->pitch( $hex_code );
}

sub bank_switch {
    my ( $bank, $n ) = @_;
    DEBUG "switch: $bank";

    if ( $bank == 65 ) {
        $n->channel( $n->channel + 1 );
    }
}

sub velocity {
    my ( $velocity, $n ) = @_;
    DEBUG "velocity: $velocity";

    # XXX many events seem to have velocity 0?
    $n->velocity( $velocity );
}

sub nlength {
    my ( $b1, $b2, $n ) = @_;
    my $l = sprintf('0x%02x%02x', $b1, $b2);
    DEBUG "length: $b1 $b2 $l";

    $n->nlength( hex($l) );
}

sub noop {}

sub write_bin {

}

1;