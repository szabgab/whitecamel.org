package t::lib::WhiteCamel;
use strict;
use warnings;

use base 'Test::Builder::Module';
use base 'Exporter';

our @EXPORT = qw(test count);

sub count { 4 }

sub test {
	my $cmd = shift;
    my $dir = 'docs';

	unlink "$dir/index.html", glob "$dir/p/*.html";

	my $Test = t::lib::WhiteCamel->builder;

	$Test->ok( !-e "$dir/index.html" );
	$Test->ok( !-e "$dir/p/yapc_eu_team.html" );

	system $cmd;

	$Test->ok( -e "$dir/index.html" );
	$Test->ok( -e "$dir/p/yapc_eu_team.html" );
}



1;

