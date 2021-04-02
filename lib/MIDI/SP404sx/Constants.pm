package MIDI::SP404sx::Constants;
use strict;
use warnings;

our $TICKS_PER_BAR = 384.0;
our $millisec_per_min = 60000;
our $ascii_character_offset = 97;
our $number_of_bank_pads = 4;
our $number_of_banks = 8;
our $secondary_bank_offset = 5;
our $pads_per_bank = 12;
our $pad_offset_magic_number = 46;
our $max_velocity = 127;
our $max_note = 127;
our $max_channel = 15;
our $path_to_samples = "./SP-404SX/SMPL/";
our $length_encoding = "008C000000000000\n00{}000000000000";

1;
