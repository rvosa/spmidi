#!/usr/bin/perl
use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'MIDI::SP404sx',
    AUTHOR        => 'Rutger Vos (RVOSA)',
    VERSION_FROM  => 'lib/MIDI/SP404sx.pm',
    ABSTRACT      => 'Convert between MIDI files and SP404sx patterns',
    PREREQ_PM     => { 'MIDI::Perl' => 0, 'Log::Log4perl' => 0 },
    dist          => { COMPRESS => 'gzip -6f', SUFFIX => 'gz', },
);