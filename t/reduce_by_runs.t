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
    my ($vals, $agged) = sum_by_runs ($runner, $agger);
    is_pdl $agged, PDL->ones(12) * 5, "aggregate sums for ndim ndarray";
    is_pdl $vals,  $runner->uniq,     "runner values for ndim ndarray";

    $runner = PDL->pdl ([1,1,1,2,2,2,1,1,1,2,2,2]);
    $runner = $runner->setbadif($runner==2);
    $agger  = PDL->ones ($runner->dims);
    ($vals, $agged) = sum_by_runs ($runner, $agger);
    $expected_val = PDL->pdl (q[1 bad 1 bad]); 
    is_pdl $agged, PDL->ones(4) * 3, "aggregate sums when runner has bad vals";
    is_pdl $vals,  $expected_val,  "runner values when runner has bad vals";
    
    $runner = PDL->pdl ([1,1,1,2,2,2,1,1,1,2,2,2]);
    $agger  = PDL->ones ($runner->dims);
    $agger->setbadat (0);
    $agger->setbadat (7);
    ($vals, $agged) = sum_by_runs ($runner, $agger);
    $expected_val = PDL->pdl (q[1 2 1 2]); 
    is_pdl $agged, PDL->new ([2,3,2,3]), "aggregate sums when agger has bad vals";
    is_pdl $vals,  $expected_val,  "runner values when agger has bad vals";
}


sub test_minima {
    my ($runner, $agger, $result, $expected_val, $expected_agg);
    my ($vals, $agged);

    $agger  = PDL->sequence (10);
    $runner = PDL->new ([1,1,1,1,2,2,2,2,3,3]);
    $result = min_by_runs ($runner, $agger);
    $expected_agg = PDL->new ([0,4,8]);
    is_pdl $result->[1], $expected_agg, 'simple min aggregate';
    is_pdl $result->[0], $runner->uniq, 'simple min values';

    $agger = PDL->sequence (10) + 0.1;
    $runner = PDL->new ([1.1,1.1,1.1,1.1,2.0,2,2,2,3.0,3]);
    $result = min_by_runs ($runner, $agger);
    $expected_agg = PDL->pdl ([0.1,4.1,8.1]);
    is_pdl $result->[1], $expected_agg, 'aggregate mins are doubles';
    
    $agger = PDL->sequence (14);
    $runner = PDL->pdl ([1.1,1.1,1.1,1.1,2.0,2,2,2,3.0,3,1.1,1.1,2,2]);
    $result = min_by_runs ($runner, $agger);
    $expected_agg = PDL->pdl ([0,4,8,10,12]);
    $expected_val = PDL->pdl ([1.1, 2, 3, 1.1, 2]);
    is_pdl $result->[1], $expected_agg, 'compare equal';
    is_pdl $result->[0], $expected_val, 'values';

    $runner = PDL->sequence (2,3,4)->divide(5, 0)->floor;
    $agger  = PDL->sequence ($runner->dims);
    ($vals, $agged) = min_by_runs ($runner, $agger);
    $expected_agg = PDL->new (0, 5, 10, 15, 20);
    is_pdl $agged, $expected_agg, "aggregate mins for ndim ndarray";
    is_pdl $vals,  $runner->uniq, "runner values for min ndim ndarray";

    $runner = PDL->pdl ([1,1,1,2,2,2,1,1,1,2,2,2]);
    $runner = $runner->setbadif($runner==2);
    $agger  = PDL->ones ($runner->dims);
    ($vals, $agged) = min_by_runs ($runner, $agger);
    $expected_val = PDL->pdl (q[1 bad 1 bad]); 
    is_pdl $agged, PDL->ones(4),  "aggregate mins when runner has bad vals";
    is_pdl $vals,  $expected_val, "runner values when min runner has bad vals";
    
    $runner = PDL->pdl ([1,1,1,2,2,2,1,1,1,2,2,2]);
    $agger  = PDL->ones ($runner->dims);
    $agger->setbadat (0);
    $agger->setbadat (7);
    ($vals, $agged) = min_by_runs ($runner, $agger);
    $expected_val = PDL->pdl (q[1 2 1 2]);
    $expected_agg = PDL->new ([1,1,1,1]);
    is_pdl $agged, $expected_agg, "aggregate mins when agger has bad vals";
    is_pdl $vals,  $expected_val,  "runner values when agger min has bad vals";

    $runner = PDL->pdl (PDL::short(), [1,1,1,2,2,2,1,1,1,2,2,2]);
    $agger  = PDL->pdl ([reverse 0..$runner->nelem-1]);
    $agger->setbadat (1);
    $agger->setbadat (2);
    $agger->setbadat (7);
    ($vals, $agged) = min_by_runs ($runner, $agger);
    $expected_val = PDL->pdl (PDL::short, q[1 2 1 2]);
    $expected_agg = PDL->new (q[11 6 3 0]);
    is_pdl $agged, $expected_agg, "aggregate mins when agger has bad vals";
    is_pdl $vals,  $expected_val,  "runner values when agger min has bad vals";
}

sub test_maxima {
    my ($runner, $agger, $result, $expected_val, $expected_agg);
    my ($vals, $agged);

    $agger = PDL->sequence (10);
    $runner = PDL->new ([1,1,1,1,2,2,2,2,3,3]);
    $result = max_by_runs ($runner, $agger);
    $expected_agg = PDL->new ([3,7,9]);
    is_pdl $result->[1], $expected_agg, 'simple max aggregate';
    is_pdl $result->[0], $runner->uniq, 'simple max values';
    
    $agger = PDL->sequence (10) + 0.1;
    $runner = PDL->new ([1.1,1.1,1.1,1.1,2.0,2,2,2,3.0,3]);
    $result = max_by_runs ($runner, $agger);
    $expected_agg = PDL->pdl ([3.1,7.1,9.1]);
    is_pdl $result->[1], $expected_agg, 'aggregate maxes are doubles';
    
    $agger = PDL->sequence (14);
    $runner = PDL->pdl ([1.1,1.1,1.1,1.1,2.0,2,2,2,3.0,3,1.1,1.1,2,2]);
    $result = max_by_runs ($runner, $agger);
    $expected_agg = PDL->pdl ([3,7,9,11,13]);
    $expected_val = PDL->pdl ([1.1, 2, 3, 1.1, 2]);
    is_pdl $result->[1], $expected_agg, 'compare equal';
    is_pdl $result->[0], $expected_val, 'values';

    $runner = PDL->sequence (2,3,4)->divide(5, 0)->floor;
    $agger  = PDL->sequence ($runner->dims);
    ($vals, $agged) = max_by_runs ($runner, $agger);
    $expected_agg = PDL->new (4, 9, 14, 19, 23);
    is_pdl $agged, $expected_agg, "aggregate mins for ndim ndarray";
    is_pdl $vals,  $runner->uniq, "runner values for min ndim ndarray";

    $runner = PDL->pdl ([1,1,1,2,2,2,1,1,1,2,2,2]);
    $runner = $runner->setbadif($runner==2);
    $agger  = PDL->ones ($runner->dims);
    ($vals, $agged) = max_by_runs ($runner, $agger);
    $expected_val = PDL->pdl (q[1 bad 1 bad]); 
    is_pdl $agged, PDL->ones(4),  "aggregate mins when runner has bad vals";
    is_pdl $vals,  $expected_val, "runner values when min runner has bad vals";
    
    $runner = PDL->pdl ([1,1,1,2,2,2,1,1,1,2,2,2]);
    $agger  = PDL->ones ($runner->dims);
    $agger->setbadat (0);
    $agger->setbadat (7);
    ($vals, $agged) = max_by_runs ($runner, $agger);
    $expected_val = PDL->pdl (q[1 2 1 2]);
    $expected_agg = PDL->new ([1,1,1,1]);
    is_pdl $agged, $expected_agg, "aggregate mins when agger has bad vals";
    is_pdl $vals,  $expected_val,  "runner values when agger min has bad vals";


    $agger = PDL->sequence (PDL::short(), 14);
    $runner = PDL->pdl ([1.1,1.1,1.1,1.1,2.0,2,2,2,3.0,3,1.1,1.1,2,2]);
    $agger->setbadat(0);
    $agger->setbadat(1);
    $result = max_by_runs ($runner, $agger);
    $expected_agg = PDL->pdl (PDL::short, [3,7,9,11,13]);
    $expected_val = PDL->pdl ($runner->type, [1.1, 2, 3, 1.1, 2]);
    is_pdl $result->[1], $expected_agg, 'agger max for short data type';
    is_pdl $result->[0], $expected_val, 'runner max for short data type';

    $agger = PDL->pdl (PDL::short(), [reverse 0..13]);
    $runner = PDL->pdl ([1.1,1.1,1.1,1.1,2.0,2,2,2,3.0,3,1.1,1.1,2,2]);
    $agger->setbadat(0);
    $agger->setbadat(1);
    $result = max_by_runs ($runner, $agger);
    $expected_agg = PDL->pdl (PDL::short, [11,9,5,3,1]);
    $expected_val = PDL->pdl ($runner->type, [1.1, 2, 3, 1.1, 2]);
    is_pdl $result->[1], $expected_agg, 'agger max for short data type, reversed ndarray';
    is_pdl $result->[0], $expected_val, 'runner max for short data type, reversed ndarray';
}

sub test_products {
    my ($runner, $agger, $result, $expected_val, $expected_agg);
    
    $agger = PDL->sequence (10);
    $runner = PDL->new ([1,1,1,1,2,2,2,2,3,3]);
    $result = product_by_runs ($runner, $agger);
    #say STDERR $result;
    $expected_agg = PDL->new ([0,840,72]);
    is_pdl $result->[1], $expected_agg, 'simple prod aggregate';
    is_pdl $result->[0], $runner->uniq, 'simple prod values';

    $agger = PDL->new ([(1.1) x 10]);
    $runner = PDL->new ([1.1,1.1,1.1,1.1,2.0,2,2,2,3.0,3]);
    $result = product_by_runs ($runner, $agger);
    #say STDERR $result;
    my $cum_val = 1.1*1.1*1.1*1.1;
    $expected_agg = PDL->pdl ([$cum_val,$cum_val,1.1*1.1]);
    is_pdl $result->[1], $expected_agg, 'aggregate products are doubles';
    
    $agger = PDL->sequence (14);
    $runner = PDL->pdl ([1.1,1.1,1.1,1.1,2.0,2,2,2,3.0,3,1.1,1.1,2,2]);
    $result = product_by_runs ($runner, $agger);
    #say STDERR $result;
    $expected_agg = PDL->pdl ([0,840,72,110,156]);
    $expected_val = PDL->pdl ([1.1, 2, 3, 1.1, 2]);
    is_pdl $result->[1], $expected_agg, 'compare equal product';
    is_pdl $result->[0], $expected_val, 'values product';

    $runner = PDL->sequence (3,4,5)->divide(5, 0)->floor;
    $agger  = PDL->ones ($runner->dims);
    my ($vals, $agged) = product_by_runs ($runner, $agger);
    is_pdl $agged, PDL->ones(12), "aggregate products for ndim ndarray";
    is_pdl $vals,  $runner->uniq, "runner values for ndim ndarray product";

    $runner = PDL->pdl ([1,1,1,2,2,2,1,1,1,2,2,2]);
    $runner = $runner->setbadif($runner==2);
    $agger  = PDL->ones ($runner->dims);
    ($vals, $agged) = product_by_runs ($runner, $agger);
    $expected_val = PDL->pdl (q[1 bad 1 bad]); 
    is_pdl $agged, PDL->ones(4), "aggregate sums when runner has bad vals";
    is_pdl $vals,  $expected_val,  "runner values when runner has bad vals";
    
    $runner = PDL->pdl ([1,1,1,2,2,2,1,1,1,2,2,2]);
    $agger  = PDL->ones ($runner->dims);
    $agger->setbadat (0);
    $agger->setbadat (7);
    ($vals, $agged) = product_by_runs ($runner, $agger);
    $expected_val = PDL->pdl (q[1 2 1 2]); 
    is_pdl $agged, PDL->new ([1,1,1,1]), "aggregate sums when agger has bad vals";
    is_pdl $vals,  $expected_val,  "runner values when agger has bad vals";
}
