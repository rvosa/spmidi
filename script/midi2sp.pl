#!/usr/bin/perl
use strict;
use warnings FATAL => 'all';
use Getopt::Long;
use Data::Dumper;
use MIDI::SP404sx::MIDIIO;

# process command line arguments
my ( $infile, $outfile );
GetOptions(
    'infile=s'  => \$infile,
    'outfile=s' => \$outfile,
);

my $pattern = MIDI::SP404sx::MIDIIO::read_midi($infile);

MIDI::SP404sx::MIDIIO::write_midi($pattern,$outfile);