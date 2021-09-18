#use strict;
#use warnings;

use ExtUtils::MakeMaker;
use PDL::Core::Dev;
 
$package = ["ReduceByRuns.pd", 'ReduceByRuns', 'PDL::ReduceByRuns'];
%hash = pdlpp_stdargs($package);

WriteMakefile( %hash );
 
sub MY::postamble {pdlpp_postamble($package)};
