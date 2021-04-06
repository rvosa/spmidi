#!/usr/bin/perl
use strict;
use warnings FATAL => 'all';
use Getopt::Long;
use MIDI::SP404sx::MIDIIO;

# process command line arguments
my ( $infile, $outfile, $blink, $channel );
GetOptions(
    'infile=s'  => \$infile,
    'outfile=s' => \$outfile,
    'blink'     => \$blink,
    'channel=i' => \$channel,
);

my $pattern = MIDI::SP404sx::MIDIIO::read_midi($infile);