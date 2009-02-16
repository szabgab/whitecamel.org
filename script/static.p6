#!/usr/bin/perl6
use v6;

# use modules from November and my own repository
BEGIN {
	@*INC.push('/home/gabor/work/november/p6w/');
	#@*INC.push('/home/gabor/work/november/p6w/', '/home/gabor/work/szabgab/trunk/Perl6-Conf/lib/');
}

use HTML::Template;
use Perl6::Conf;

#run "rm -fr www/p6";
#run "mkdir www/p6";
run "mkdir www/p";


# Cron-job on my notebook, 
#   Perl 5 - check if rakudo is available, mirror the files from the remote location 
#            if any file changed call the  Perl 6 script (and also notify me somehow)
#   Perl 6 - build the pages from what we have now and the files collected from the people
#            format starts to be simple text and then we'll switch to json
#   whitecamel.ini

# title =
# url = http://...
# blog = http:// url to rss or atom feed of the blog

# [about]
# text about 

# [Conferences]
# title = url
# title = url

# give me an e-mail address to fetch avtar



my $dir = '/home/gabor/work/www.perl.org/advocacy/white_camel/';

my $time = time;
$time = "$time"; # to avoid warning "Param TIME is a Num

# TODO: should be checking if the file exists and if we can read it
# and if open was successful (catch exceptions?)
my %conf = Perl6::Conf.from_file('data/people.conf').parse;
#%conf.perl.say;
#exit;

my %blob = read_html_files(%conf);
#%blob.perl.say;
#exit;
#my %blob;
my @people = map { {NAME => $_} }, %conf.keys.sort;
#@people.perl.say;


{
	my %params;
	%params<TIME> = $time;
	%params<TITLE> = "About the WhiteCamel.org web site";
	fill_template('about', %params);
}

{
	my %params;
	%params<TIME>   = $time;
	%params<TITLE>  = "White Camel Award Winners";
	%params<PEOPLE> = @people;
	#%params.perl.say;
	fill_template('index', %params);
}

{
	my %params;
	%params<TIME> = $time;
	%params<TITLE> = "News of WhiteCamel.org";
	fill_template('news', %params);
}; #TODO ; needed due to parsing bug

for %conf.keys -> $person {
	say "processing '$person'";
	my %params;
	%params<TIME>  = $time;
	%params<TITLE> = $person;
	%params<NAME>  = $person;
	%params<BLOB>  = %blob{$person};
	if (%blob{$person} eq '') {
		say "WARN person '$person' has no blob";
	}
	%blob.delete($person);
	my $file = %conf{$person}{"name"} ?? %conf{$person}{"name"} !! $person;
	fill_template('person', "p/{$file}", %params);
}
for %blob.keys -> $person {
	say "WARN left over blob entry for '$person'";
}


# collect data from the html files 
sub read_html_files {
	my $in;
	my %blob;
	
	# TODO: not implemented in Rakudo yet
	#use IO::Dir;
	#my $dh = IO::Dir::open($dir);

	for 1999..2008 -> $year {
		my $file = $dir ~ $year ~ '.html';
		say "processing $file";
		my $fh = open $file, :r;
		my $name = '';
		my $text = '';
		for $fh.readline -> $line {
			if ( $line ~~ / \<dt\>\<b\>[\<tt\>]? (.*?) [\<\/tt\>]?\<\/b\> / ) {
				#say "----";
				$name = $0;
				$name .= subst( /Perl\s+User\s+Groups\s+\-\s+/, '');
				$name .= subst( /Perl\s+Community\s+\-\s+/,     '');
				$name .= subst( /Perl\s+Advocacy\s+\-\s+/,      '');
				#say "NAME: $name";
			}
			# TODO: Rakudo does not implement ff (flip-flop) yet.
			#if ( $line ~~ / \<dd\> / ff $line ~~ / \<\/dd\> | \<br\>\<br\> | \<\/dl\> /) {
			#	say $line;
			#}
			if ( $line ~~ / \<dd\> (.*)/ ) {
				$in = 1;
				$text = "$0 ";
				#say "IN";
			} elsif ( $in and $line ~~ / (.*)  (\<\/dd\> | \<br\>\<br\> | \<\/dl\>) /) {
				$in = 0;
				$text ~= $0;
				#say "OUT $text";
				%blob{$name} = $text;
				$text = '';
			} elsif ($in) {
				#say "ADD";
				$text ~= "$line ";
			}
			#say $line;
		}
	}
	return %blob;
}


multi sub fill_template($name, %params) {
	return fill_template($name, $name, %params);
}

multi sub fill_template($source, $target, %params) {
	my $path = "p6templates/$source.tmpl";
	#say $path;
    my $template = HTML::Template.from_file($path);
    $template.with_params(%params);
    my $out = open "www/$target.html", :w;
    #say '---';
    #say $template.output;
    $out.print($template.output);

    return;
}

