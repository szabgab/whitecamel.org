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



my $time = time;
$time = "$time"; # to avoid warning "Param TIME is a Num

# TODO: should be checking if the file exists and if we can read it
# and if open was successful (catch exceptions?)
my %conf = Perl6::Conf.from_file('data/people.conf').parse;
#%conf.perl.say;
#exit;

my %blob = read_personal_files(%conf);
#%blob.perl.say;
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
	%params<TITLE> = "Sponsors of the White Camel Award";
	fill_template('sponsors', %params);
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

sub read_personal_files(%c) {
	my %text;
	for %c.keys -> $person {
		if %c{$person}<id> {
			#say %c{$person}<id>;
			#my %p = Perl6::Conf.from_file("data/people/{%c{$person}<file>}").parse;
			#%p.perl.say;
			#%text{$person} = %p<text>;
			%text{$person} = slurp("data/people/{%c{$person}<id>}.txt");
		} else {
			say "Missing id from {$person}";
		}
	}
	return %text;
}
