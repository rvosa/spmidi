package MIDI::SP404sx::PTNIO;
use strict;
use warnings;
use Data::Dumper;
use MIDI::SP404sx::Note;
use MIDI::SP404sx::Pattern;
use MIDI::SP404sx::Constants;
use Log::Log4perl qw(:easy);

my $BLOCK_SIZE=1024;

sub read_bin {
    my $file = shift;
    open my $fh, '<', $file or die $!;
    binmode($fh);
    my $buf;
    my $offset = 0;
    my @result;
    my $i = 0;

    ### this is just for formatted printing of the byte sequence
    # print join( "\t", qw(event next pad bank ? vel ? length) ), "\n";
    # print 1;
    ###

    while( read( $fh, $buf, $BLOCK_SIZE, $offset * $BLOCK_SIZE ) ){
	    for( split( //, $buf ) ) {
            my $hex = ord( $_ );

            ### this is just for formatted printing of the byte sequence
            # print "\t$hex";
            # $i++;
            # unless ( $i % 8 ) {
            #     print "\n";
            #     print $i/8 + 1;
            # }
            ###

            push @result, $hex;
	    }
	    $offset++;
    }
    close( $fh );
    return decode(@result);
}

sub decode {
    my @ints = @_;
    my ( $next, $pad, $bank, $velocity, $isnote, $length ) = ( 0, 1, 2, 4, 5, 6);
    my $pattern  = MIDI::SP404sx::Pattern->new( nlength => $ints[-7] );
    my $position = 0;
    for ( my $i = 0; $i <= ( $#ints - 16 ); $i += 8 ) {
        if ( $ints[$isnote+$i] ) {
            my $channel = $ints[$bank+$i] ? 1 : 0;
            my $nlength = hex(sprintf('0x%02x%02x',$ints[$length+$i],$ints[$length+$i+1]))/$MIDI::SP404sx::Constants::PPQ;
            MIDI::SP404sx::Note->new(
                pitch    => $ints[$pad+$i],
                velocity => $ints[$velocity+$i],
                nlength  => $nlength,
                channel  => $channel,
                pattern  => $pattern,
                position => $position / $MIDI::SP404sx::Constants::PPQ,
            );
        }
        $position += $ints[$next];
    }
    return $pattern;
}

sub write_bin {
    my ( $pattern, $outfile ) = @_;
    open my $out, '>:raw', $outfile or die "Unable to open: $!";
    print $out pack('s<', 255);
    close $out;
}

1;