package t::lib::WhiteCamel;
use strict;
use warnings;

use base 'Test::Builder::Module';
use base 'Exporter';

our @EXPORT = qw(test count);

sub count { 4 }

sub test {
	my $cmd = shift;

	unlink 'www/index.html', glob 'www/p/*.html';

	my $Test = t::lib::WhiteCamel->builder;

	$Test->ok( !-e 'www/index.html' );
	$Test->ok( !-e 'www/p/yapc_eu_team.html' );

	system $cmd;

	$Test->ok( -e 'www/index.html' );
	$Test->ok( -e 'www/p/yapc_eu_team.html' );
}



1;

