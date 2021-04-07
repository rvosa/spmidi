package MIDI::SP404sx::PTNIO;
use strict;
use warnings;
use Data::Dumper;
use MIDI::SP404sx::Note;
use MIDI::SP404sx::Pattern;
use MIDI::SP404sx::Constants;
use Log::Log4perl qw(:easy);

my $BLOCK_SIZE=1024;

sub read_pattern {
    my $class = shift;
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

#- next_sample
#- pad_code
#- bank_switch
#- unknown1
#- velocity
#- unknown2
#- length (note: 2 bytes)

sub write_pattern {
    my $class = shift;
    my ( $pattern, $outfile ) = @_;
    open my $out, '>:raw', $outfile or die "Unable to open: $!";
    my $writer = sub { print $out pack('C', shift ) };
    my @notes = sort { $a->position <=> $b->position } $pattern->notes;
    for my $i ( 0 .. $#notes ) {
        my $n = $notes[$i];

        # generate spacers
        my ( $next_sample, @spacers );
        if ( my $o = $notes[$i+1] ) {
            $next_sample = int( ( $o->position - $n->position ) * $MIDI::SP404sx::Constants::PPQ );
            while ( $next_sample > 255 ) {
                push @spacers, [ 255, 128, 0, 0, 0, 0 ];
                $next_sample -= 255;
            }
        }

        # write focal note
        $writer->( $next_sample );         # next_sample
        $writer->( $n->pitch );            # pad_code
        $writer->( $n->channel ? 64 : 0 ); # bank_switch
        $writer->( 0 );                    # unknown1
        $writer->( $n->velocity );         # velocity
        $writer->( 64 );                   # unknown2
        print $out pack('S>', int( $n->nlength * $MIDI::SP404sx::Constants::PPQ ) ); # length as long

        # write spacers
        for my $s ( @spacers ) {
            $writer->($_) for @$s;
            print $out pack('S>', 255);
        }
    }

    # write footer
    $writer->($_) for ( 0, 140, 0, 0, 0, 0 );
    print $out pack('S>', 0);
    $writer->($_) for ( 0, $pattern->nlength, 0, 0, 0, 0 );
    print $out pack('S>', 0);

    close $out;
}

1;