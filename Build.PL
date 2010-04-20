use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'IPC::Open3::System',
    license             => 'perl',
    dist_author         => 'Ryan C. Thompson <rct@thompsonclan.org>',
    dist_version_from   => 'lib/IPC/Open3/System.pm',
    requires => {
        'Test::More' => 0,
        'version'    => 0,
    },
    add_to_cleanup      => [ 'IPC-Open3-System-*' ],
);

$builder->create_build_script();
