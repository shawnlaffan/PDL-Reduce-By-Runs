use 5.006;
use strict;
use warnings;

use ExtUtils::MakeMaker;
use PDL::Core::Dev;
 
my $package = ["ReduceByRuns.pd", 'ReduceByRuns', 'PDL::ReduceByRuns'];
my %pd_hash = pdlpp_stdargs($package);

my %main_hash = (
    NAME             => 'PDL::ReduceByRuns',
    AUTHOR           => q{Shawn Laffan <shawnlaffan@gmail.com>},
    #VERSION_FROM     => 'lib/PDL/ReduceByRuns.pm',
    #ABSTRACT_FROM    => 'lib/PDL/ReduceByRuns.     pm',
    LICENSE          => 'artistic_2',
    PL_FILES         => {},
    MIN_PERL_VERSION => 5.010,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'Test::More' => 0,
        'Test::PDL' => 0,
        'Statistics::Descriptive' => "3.06",
        "Devel::Symdump" => "0",
    },
    PREREQ_PM => {
        #  PDL:: versions should be able to go lower, but need to start somewhere
        "PDL"        => "2.012",
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'PDL-ReduceByRuns-*' },
    META_MERGE => {
        'meta-spec' => { version => 2 },
        resources => {
            repository => {
                type => 'git',
                url  => 'https://github.com/shawnlaffan/PDL-ReduceByRuns',
            },
            bugtracker => {
                web => 'https://github.com/shawnlaffan/PDL-ReduceByRuns/issues/',
            },
        },
    },
);

@pd_hash{keys %main_hash} = values %main_hash;
WriteMakefile( %pd_hash );
 
sub MY::postamble {pdlpp_postamble($package)};
