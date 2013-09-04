use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME   => 'App-Power-Perl',
    AUTHOR => q{Gabor Szabo <szabgab@cpan.com>},

    VERSION_FROM        => 'lib/App/Power/Perl.pm',
    LICENSE => 'perl',
    PREREQ_PM => {
		'Path::Tiny'   => 0.030;
        'Prima'        => 1.37,
        'Moo'          => 1.003,
        'MooX'         => 0.101,
        'MooX::late'   => 0.014,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES    => 'App-Power-Perl-*' },
);
