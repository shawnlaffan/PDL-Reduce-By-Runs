use 5.006;
use strict;
use warnings;

use ExtUtils::MakeMaker;
use PDL::Core::Dev;
 
my $package = ["ReduceByRuns.pd", 'ReduceByRuns', 'PDL::ReduceByRuns'];
my %pd_hash = pdlpp_stdargs($package);

WriteMakefile( %pd_hash );
 
sub MY::postamble {pdlpp_postamble($package)};
