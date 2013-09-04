use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME   => 'App-Power-Perl',
    AUTHOR => q{Gabor Szabo <szabgab@cpan.com>},

    VERSION_FROM        => 'lib/App/Power/Perl.pm',
    LICENSE => 'perl',
    PREREQ_PM => {
        'Prima' => 0,
        'Moo'          => 0,
        'MooX'         => 0,
        'MooX::late'   => 0,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES    => 'App-Power-Perl-*' },
);
