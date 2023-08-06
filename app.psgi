use strict;
use warnings;

use Plack::Builder;
use Plack::App::File;

my $root_dir = './docs/';
my $app = Plack::App::File->new({ root => $root_dir })->to_app;

builder {
      enable "Plack::Middleware::DirIndex", root => $root_dir;
      $app;
}
