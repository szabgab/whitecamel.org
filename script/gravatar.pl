#!/usr/bin/perl
use strict;
use warnings;

use v5.10;

use Gravatar::URL qw(gravatar_url gravatar_id);
use LWP::Simple   qw(getstore);

my ($email, $name) = @ARGV;
die "Usage: $0 email name\n" if not $name;

#say gravatar_id($email);
#say gravatar_url(email => $email);
getstore gravatar_url(email => $email), "$name.png";

