use strict;
use warnings;
use ExtUtils::MakeMaker;

use lib 'inc';
use ExtUtils::MakeMaker::Dist::Zilla::Develop;
use MMHelper;

# keep this code consistent with the [MakeMaker::Awesome] arguments in dist.ini
WriteMakefile(
    NAME     => 'List::Gather',
    VERSION_FROM => 'lib/List/Gather.pm',
    NORECURS => 1,
    INSTALLMAN1DIR => 'none',
    INSTALLMAN3DIR => 'none',
    CCFLAGS => ( $Config::Config{ccflags} || '' ) . ' -I. -Wall -Wdeclaration-after-statement',
    _mm_args(),
);
