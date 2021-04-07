#!/usr/bin/perl
use strict;
use warnings FATAL => 'all';
use Getopt::Long;
use Data::Dumper;
use MIDI::SP404sx::PTNIO;

# process command line arguments
my ( $infile, $outfile );
GetOptions(
    'infile=s'  => \$infile,
    'outfile=s' => \$outfile,
);

my $pattern = MIDI::SP404sx::PTNIO::read_bin($infile);

print Dumper( $pattern );