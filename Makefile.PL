use ExtUtils::MakeMaker;

my %opts = (
	'NAME'      => 'Whitecamel',
	'VERSION'   => '0.1',
	'PREREQ_PM' => {
		'Test::More' => 0.47,
	},
);
WriteMakefile( %opts );
