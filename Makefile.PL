use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'IPC::Open3::System',
    AUTHOR              => 'Ryan C. Thompson <rct@thompsonclan.org>',
    VERSION_FROM        => 'lib/IPC/Open3/System.pm',
    ABSTRACT_FROM       => 'lib/IPC/Open3/System.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'version'    => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'IPC-Open3-System-*' },
);
