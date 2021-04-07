#!/bin/env perl
use strict;
use warnings;
use Getopt::Long;
use MIDI::SP404sx::PTNIO;
use MIDI::SP404sx::MIDIIO;

# process command line arguments
my ( $infile, $outfile, $verbosity );
GetOptions(
    'infile=s'  => \$infile,
    'outfile=s' => \$outfile,
    'verbose+'  => \$verbosity,
);

# will be input and output classes
my ( $reader, $writer );

# determine the input
if ( $infile =~ /\.mid$/i ) {
    $reader = 'MIDI::SP404sx::MIDIIO';
}
elsif ( $infile =~ /\.BIN/i ) {
    $reader = 'MIDI::SP404sx::PTNIO';
}
else {
    die "No reader for file $infile";
}

# determine the output
if ( $outfile =~ /\.BIN$/i ) {
    $writer = 'MIDI::SP404sx::PTNIO';
}
elsif ( $outfile =~ /\.mid$/i ) {
    $writer = 'MIDI::SP404sx::MIDIIO';
}
else {
    die "No writer for file $outfile";
}

# do the conversion
$writer->write_pattern(
    $reader->read_pattern($infile),
    $outfile
);
