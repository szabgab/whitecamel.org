use strict;
use warnings;

use Test::More skip_all => 'The perl6 implementation is not up to date any more';
use Test::More;
use t::lib::WhiteCamel;

plan tests => count();


test("perl6 script/static.p6");
