package inc::MakeMaker;

use Moose;
use lib 'inc';
use MMHelper;

extends 'Dist::Zilla::Plugin::MakeMaker::Awesome';

around _build_MakeFile_PL_template => sub {
    my $self = shift;
    my $orig = shift;

    my $tmpl = $self->$orig(@_);

    my $ccflags = MMHelper::ccflags_dyn();
    $tmpl =~ s/^(WriteMakefile\()/\$WriteMakefileArgs{CCFLAGS} = $ccflags;\n\n$1/m;

    $tmpl =~ s/^(use ExtUtils::MakeMaker)/MMHelper::header_generator() . "\n$1"/em
        or die;

    return $tmpl;
};

around _build_WriteMakefile_args => sub {
    my $self = shift;
    my $orig = shift;

    return {
        %{ $self->$orig(@_) },
        MMHelper::mm_args(),
    };
};

1;
