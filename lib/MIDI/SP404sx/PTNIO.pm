package MIDI::SP404sx::PTNIO;
use strict;
use warnings;
use Data::Dumper;
use MIDI::SP404sx::Note;
use MIDI::SP404sx::Pattern;
use MIDI::SP404sx::Constants;
use Log::Log4perl qw(:easy);

Log::Log4perl->easy_init($INFO);

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
		    # printf( "0x%02x ", $hex );
            # $i++;
            # unless ( $i % 8 ) {
            #     print "\n";
            # }
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
        \&noop,
        \&nlength,
    );
    my $i = 0;
    my $p = MIDI::SP404sx::Pattern->new();
    my $n = MIDI::SP404sx::Note->new( pattern => $p );
    for my $h ( @hex ) {
        $map[$i]->($h,$n);
        if ( $i < 7 ) {
            $i++;
        }
        else {
            INFO Dumper($n);
            $i = 0;
            $n = MIDI::SP404sx::Note->new( pattern => $p );
        }
    }
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
    my $ppb = $MIDI::SP404sx::Constants::pads_per_bank;
    my $real_code = $hex_code - $MIDI::SP404sx::Constants::pad_offset_magic_number;
    my $pad = $real_code % $ppb;
    my $bank = ( $real_code - $pad ) / $ppb;
    if ( $bank > $MIDI::SP404sx::Constants::secondary_bank_offset ) {
        $bank = ( $real_code - $pad ) / ( $ppb * 2 );
    }
    if ( $pad == 0 ) {
        $pad = 12;
        $bank--;
    }

    # pitch mapped back to MIDI note nr, reporting bank and pad in log
    $n->pitch( $pad + $MIDI::SP404sx::Constants::pad_offset_magic_number );
    INFO "$real_code bank: $bank pad: $pad";
}

sub bank_switch {
    my ( $bank, $n ) = @_;
    DEBUG "switch: $bank";

    # 0 means base bank, otherwise upper/blinking
    my $sw = $bank ? !!$bank : 0;
    $n->channel( $sw );
}
sub velocity {
    my ( $velocity, $n ) = @_;
    DEBUG "velocity: $velocity";

    # XXX many events seem to have velocity 0?
    $n->velocity( $velocity );
}

sub nlength {
    my ( $length, $n ) = @_;
    DEBUG "length: $length";

    $n->nlength( $length );
}

sub noop {}

sub write_bin {

}

1;