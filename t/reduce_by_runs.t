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
    my ($x, $y, $summed, $expected);
    
    $x = PDL->new ([(1) x 10]);
    $y = PDL->new ([1,1,1,1,2,2,2,2,3,3]);
    $summed = sum_by_runs ($x, $y);
    #say STDERR $summed;
    $expected = PDL->new ([4,4,2]);
    is_pdl $summed, $expected, 'simple sums';
    
    $x = PDL->new ([(1.1) x 10]);
    $y = PDL->new ([1.1,1.1,1.1,1.1,2.0,2,2,2,3.0,3]);
    $summed = sum_by_runs ($x, $y);
    #say STDERR $summed;
    $expected = PDL->pdl ([4.4,4.4,2.2]);
    is_pdl $summed, $expected, 'x has doubles';
    
    $x = PDL->pdl ([(1) x 14]);
    $y = PDL->pdl ([1.1,1.1,1.1,1.1,2.0,2,2,2,3.0,3,1.1,1.1,2,2]);
    $summed = sum_by_runs ($x, $y);
    #say STDERR $summed;
    $expected = PDL->pdl ([4,4,2,2,2]);
    is_pdl $summed, $expected, 'compare equal';
}

