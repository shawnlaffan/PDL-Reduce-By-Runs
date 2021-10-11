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
    my ($x, $y, $result, $expected);
    
    $x = PDL->new ([(1) x 10]);
    $y = PDL->new ([1,1,1,1,2,2,2,2,3,3]);
    $result = sum_by_runs ($x, $y);
    #say STDERR $result;
    $expected = PDL->new ([4,4,2]);
    is_pdl $result, $expected, 'simple sums';
    
    $x = PDL->new ([(1.1) x 10]);
    $y = PDL->new ([1.1,1.1,1.1,1.1,2.0,2,2,2,3.0,3]);
    $result = sum_by_runs ($x, $y);
    #say STDERR $result;
    $expected = PDL->pdl ([4.4,4.4,2.2]);
    is_pdl $result, $expected, 'x has doubles';
    
    $x = PDL->pdl ([(1) x 14]);
    $y = PDL->pdl ([1.1,1.1,1.1,1.1,2.0,2,2,2,3.0,3,1.1,1.1,2,2]);
    $result = sum_by_runs ($x, $y);
    #say STDERR $result;
    $expected = PDL->pdl ([4,4,2,2,2]);
    is_pdl $result, $expected, 'compare equal';

    $y = PDL->sequence (3,4,5)->divide(5, 0)->floor;
    $x = PDL->ones ($y->dims);
    say STDERR '=====';
    say STDERR $y;
    say STDERR $x;
    $result = sum_by_runs ($x, $y);
    say STDERR $result;
    
    $x = $x->flat->sever;
    $y = $y->flat->sever;
    say STDERR '=====';
    say STDERR $y;
    say STDERR $x;
    $result = sum_by_runs ($x, $y);
    say STDERR $result;
}

sub test_maxima {
    return;
    my ($x, $y, $result, $expected);
    
    $x = PDL->new ([1..10]);
    $y = PDL->new ([1,1,1,1,2,2,2,2,3,3]);
    $result = max_by_runs ($x, $y);
    #say STDERR $result;
    $expected = PDL->new ([4,8,10]);
    is_pdl $result, $expected, 'simple sums';
    
    $x = PDL->new ([1..10]) + .1;
    $y = PDL->new ([1.1,1.1,1.1,1.1,2.0,2,2,2,3.0,3]);
    $result = max_by_runs ($x, $y);
    #say STDERR $result;
    $expected = PDL->pdl ([4.1,8.1,10.1]);
    is_pdl $result, $expected, 'x has doubles';
    
    $x = PDL->pdl ([1..14]) * .5;
    $y = PDL->pdl ([1.1,1.1,1.1,1.1,2.0,2,2,2,3.0,3,1.1,1.1,2,2]);
    $result = max_by_runs ($x, $y);
    #say STDERR $result;
    $expected = PDL->pdl ([4.5,8.5,10.5,12.5,14.5]);
    is_pdl $result, $expected, 'compare equal';
    
    
}
