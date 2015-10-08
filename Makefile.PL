use strict;
use warnings;
use ExtUtils::MakeMaker;

use lib 'inc';
use ExtUtils::MakeMaker::Dist::Zilla::Develop;
use MMHelper;

eval MMHelper::header_generator() or die $@;

WriteMakefile(
    NAME     => 'List::Gather',
    VERSION_FROM => 'lib/List/Gather.pm',
    NORECURS => 1,
    CCFLAGS  => MMHelper::ccflags_static('dev'),
    INSTALLMAN1DIR => 'none',
    INSTALLMAN3DIR => 'none',
    MMHelper::mm_args(),
);
