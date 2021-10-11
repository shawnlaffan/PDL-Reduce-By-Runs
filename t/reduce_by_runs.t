use 5.010;
use strict;
use warnings;

use Test::More;

use rlib;
use lib 't/lib';

use PDL::Lite;
use PDL::ReduceByRuns;
use Test::PDL qw( is_pdl :deep );


use Devel::Symdump;
my $obj = Devel::Symdump->rnew(__PACKAGE__); 
my @subs = grep {$_ =~ 'main::test_'} $obj->functions();


exit main( @ARGV );


sub main {
    my @args  = @_;

    if (@args) {
        for my $name (@args) {
            die "No test method test_$name\n"
                if not my $func = (__PACKAGE__->can( 'test_' . $name ) || __PACKAGE__->can( $name ));
            $func->();
        }
        done_testing;
        return 0;
    }

    foreach my $sub (sort @subs) {
        no strict 'refs';
        $sub->();
    }
    
    done_testing;
    return 0;
}

sub test_sums {
    my ($runner, $agger, $result, $expected_val, $expected_agg);
    
    $agger = PDL->new ([(1) x 10]);
    $runner = PDL->new ([1,1,1,1,2,2,2,2,3,3]);
    $result = sum_by_runs ($runner, $agger);
    #say STDERR $result;
    $expected_agg = PDL->new ([4,4,2]);
    is_pdl $result->[1], $expected_agg, 'simple sum aggregate';
    is_pdl $result->[0], $runner->uniq, 'simple sum values';
    
    $agger = PDL->new ([(1.1) x 10]);
    $runner = PDL->new ([1.1,1.1,1.1,1.1,2.0,2,2,2,3.0,3]);
    $result = sum_by_runs ($runner, $agger);
    #say STDERR $result;
    $expected_agg = PDL->pdl ([4.4,4.4,2.2]);
    is_pdl $result->[1], $expected_agg, 'aggregate sums are doubles';
    
    $agger = PDL->pdl ([(1) x 14]);
    $runner = PDL->pdl ([1.1,1.1,1.1,1.1,2.0,2,2,2,3.0,3,1.1,1.1,2,2]);
    $result = sum_by_runs ($runner, $agger);
    #say STDERR $result;
    $expected_agg = PDL->pdl ([4,4,2,2,2]);
    $expected_val = PDL->pdl ([1.1, 2, 3, 1.1, 2]);
    is_pdl $result->[1], $expected_agg, 'compare equal';
    is_pdl $result->[0], $expected_val, 'values';

    $runner = PDL->sequence (3,4,5)->divide(5, 0)->floor;
    $agger  = PDL->ones ($runner->dims);
    #say STDERR '=====';
    #say STDERR $runner;
    #say STDERR $agger;
    my ($vals, $agged) = sum_by_runs ($runner, $agger);
    is_pdl $agged, PDL->ones(12) * 5, "aggregate sums for ndim ndarray";
    is_pdl $vals,  $runner->uniq,     "runner values for ndim ndarray";
    #say STDERR "Aggregated: " . $agged;
    #say STDERR "Values:     " . $vals;
}

#sub test_maxima {
#    return;
#    my ($runner, $agger, $result, $expected_agg);
#    
#    $agger = PDL->new ([1..10]);
#    $runner = PDL->new ([1,1,1,1,2,2,2,2,3,3]);
#    $result = max_by_runs ($runner, $agger);
#    #say STDERR $result;
#    $expected_agg = PDL->new ([4,8,10]);
#    is_pdl $result, $expected_agg, 'simple sums';
#    
#    $agger = PDL->new ([1..10]) + .1;
#    $runner = PDL->new ([1.1,1.1,1.1,1.1,2.0,2,2,2,3.0,3]);
#    $result = max_by_runs ($runner, $agger);
#    #say STDERR $result;
#    $expected_agg = PDL->pdl ([4.1,8.1,10.1]);
#    is_pdl $result, $expected_agg, 'x has doubles';
#    
#    $agger = PDL->pdl ([1..14]) * .5;
#    $runner = PDL->pdl ([1.1,1.1,1.1,1.1,2.0,2,2,2,3.0,3,1.1,1.1,2,2]);
#    $result = max_by_runs ($runner, $agger);
#    #say STDERR $result;
#    $expected_agg = PDL->pdl ([4.5,8.5,10.5,12.5,14.5]);
#    is_pdl $result, $expected_agg, 'compare equal';
#    
#    
#}
