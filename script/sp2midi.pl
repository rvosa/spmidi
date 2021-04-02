#!/usr/bin/perl
use strict;
use warnings FATAL => 'all';
use Getopt::Long;
use MIDI::SP404sx::BinaryUtils;

# process command line arguments
my ( $infile, $outfile, $blink, $channel );
GetOptions(
    'infile=s'  => \$infile,
    'outfile=s' => \$outfile,
    'blink'     => \$blink,
    'channel=i' => \$channel,
);

my @hex = MIDI::SP404sx::BinaryUtils::read_bin($infile);
MIDI::SP404sx::BinaryUtils::decode_hex(@hex);