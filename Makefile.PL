use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
	NAME   => 'App-Power-Perl',
	AUTHOR => q{Gabor Szabo <szabgab@cpan.org>},

	VERSION_FROM        => 'lib/App/Power/Perl.pm',
	LICENSE => 'perl',
	PREREQ_PM => {
		'Data::Dumper'         => 0,
		'JSON::Tiny'           => 0, # 0.32,
		'Moo'                  => 0, # 1.003,
		'MooX'                 => 0, # 0.101,
		'MooX::late'           => 0, # 0.014,
		'MooX::Options'        => 0, # 3.83
		'Path::Tiny'           => 0, # 0.030,
		'Path::Iterator::Rule' => 0, # 1.005
		'Prima'                => 0, # 1.37,
	},
	dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
	clean => { FILES    => 'App-Power-Perl-*' },
);
