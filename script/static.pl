#!/usr/bin/perl
use v5.8;
use strict;
use warnings;

use Config::Tiny;
use Data::Dumper qw(Dumper);
use HTML::Template;
use List::Util qw(max);

sub say { print @_, "\n" };

mkdir "www/p";

my $time = localtime;

my $conf = Config::Tiny->read('data/people.conf');
die "Could not read config file: $Config::Tiny::errstr" if not defined $conf;
#print Dumper $conf;

my %blob = read_personal_files($conf);
#print Dumper \%blob;

my @people;
foreach my $name (sort keys %$conf) {
	my %p = (
		NAME => $name,
		YEAR => $conf->{$name}{year},
		ID   => $conf->{$name}{id},
	);
	$p{IMG} = "$conf->{$name}{id}.jpg" if -e "www/img/$conf->{$name}{id}.jpg";
	push @people, \%p; 
}

my $year = max map { $conf->{$_}{year} } sort keys %$conf;
my @current = grep { $_->{YEAR} eq $year } @people;


{
	my %params = (
		TIME    => $time,
		TITLE   => "White Camel Award Winners",
		PEOPLE  => \@people,
		CURRENT => \@current,
		YEAR    => $year,
	);
	fill_template('index', 'index', %params);
}

{
	my %params = (
		TIME  => $time,
		TITLE => "Sponsors of the White Camel Award",
	);
	fill_template('sponsors', 'sponsors', %params);
}

for my $person (keys %$conf) {
	say "processing '$person'\n";
	my %params = (
		TIME  => $time,
		TITLE => $person,
		URL   => ($conf->{$person}{url} || ''),
		YEAR  => $conf->{$person}{year},
		NAME  => $person,
		BLOB  => $blob{$person},
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
    open my $out, '>', "www/$target.html" or die;
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

