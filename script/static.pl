#!/usr/bin/perl
use v5.8;
use strict;
use warnings;

use Config::Tiny;
use Data::Dumper qw( Dumper );
use HTML::Template;
use List::Util qw( max );
use POSIX qw( ceil );

sub say { print @_, "\n" };

my $dir = 'docs';
if (@ARGV) {
    $dir = shift @ARGV;
}
mkdir $dir;
mkdir "$dir/p";

my $time = localtime;

my $conf = Config::Tiny->read('data/people.conf');
die "Could not read config file: $Config::Tiny::errstr" if not defined $conf;
#print Dumper $conf;

my %blob = read_personal_files($conf);
#print Dumper \%blob;

my @people;
foreach my $name (sort { lc $a cmp lc $b } keys %$conf) {
	my %p = (
		NAME => $name,
		YEAR => $conf->{$name}{year},
		ID   => $conf->{$name}{id},
	);
	foreach my $ext (qw(jpg png)) {
		$p{IMG} = "$conf->{$name}{id}.$ext" if -e "$dir/img/$conf->{$name}{id}.$ext";
	}
	push @people, \%p;
}

my $year = max map { $conf->{$_}{year} } sort keys %$conf;
my @current = grep { $_->{YEAR} eq $year } @people;

# split @people into 3 columns, as per index page layout
my (@people_col1, @people_col2, @people_col3);
my $num_rows = ceil(@people / 3);
for my $row_num (0 .. $num_rows-1) {
   my ($col1, $col2, $col3) = @people[ grep { $_ < @people } map { $row_num + $num_rows*$_ } 0..2 ];
   push @people_col1, $col1 if defined $col1;
   push @people_col2, $col2 if defined $col2;
   push @people_col3, $col3 if defined $col3;
}

# -- index page --
{
	my %params = (
		TIME    => $time,
		TITLE   => "White Camel Award Winners",
		PEOPLE_COL1  => \@people_col1,
		PEOPLE_COL2  => \@people_col2,
		PEOPLE_COL3  => \@people_col3,
		CURRENT => \@current,
		YEAR    => $year,
	);
	fill_template('index', 'index', %params);
}

# -- sponsors page --
{
	my %params = (
		TIME  => $time,
		TITLE => "Sponsors of the White Camel Award",
	);
	fill_template('sponsors', 'sponsors', %params);
}

# -- individual people pages --
for my $person (keys %$conf) {
	say "processing '$person'\n";
	my %params = (
		TIME  => $time,
		TITLE => $person.' - Perl White Camel Awards',
		URL   => ($conf->{$person}{url} || ''),
		YEAR  => $conf->{$person}{year},
		NAME  => $person,
		BLOB  => $blob{$person},
        PAUSE => $conf->{$person}{pause},
		GITHUB  => $conf->{$person}{github},
		LINKEDIN  => $conf->{$person}{linkedin},
    );
	if ($blob{$person} eq '') {
		warn "person '$person' has no blob";
	}
	delete $blob{$person};
	fill_template('person', "p/$conf->{$person}{id}", %params);
}
for my $person (keys %blob) {
	say "WARN left over blob entry for '$person'";
}


sub fill_template {
	my ($source, $target, %params) = @_;
	my $path = "templates/$source.tmpl";
	#say $path;
    my $template = HTML::Template->new(die_on_bad_params => 0, filename => $path);
    $template->param(%params);
    open my $out, '>', "$dir/$target.html" or die;
    print $out $template->output;
    return;
}


sub read_personal_files {
	my $c = shift;
	my %text;
	for my $person (keys %$c) {
		if ($c->{$person}{id}) {
			$text{$person} = read_file("data/people/$c->{$person}{id}.txt");
		} else {
			say "Missing id from $person";
		}
	}
	return %text;
}

sub read_file {
	my $file = shift;
	open my $fh, '<', $file or die "Could not open '$file' $!";
	local $/ = undef;
	return <$fh>;
}

