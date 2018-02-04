package List::Gather;
# ABSTRACT: Construct lists procedurally without temporary variables

use strict;
use warnings;

our $VERSION = '0.14';

use Devel::CallParser;
use Devel::CallChecker;

use XSLoader;

XSLoader::load(
    __PACKAGE__,
    $VERSION,
);

require B::Hooks::EndOfScope
    unless _QPARSE_DIRECTLY();

my @keywords;
BEGIN { @keywords = qw(gather take gathered) }

use Sub::Exporter -setup => {
    exports => [@keywords],
    groups  => { default => [@keywords] },
};

=head1 SYNOPSIS

  use List::Gather;

  my @list = gather {
      while (<$fh>) {
          next if /^\s*$/;
          next if /^\s*#/;
          last if /^(?:__END__|__DATA__)$/;
          take $_ if some_predicate($_);
      }

      take @defaults unless gathered;
  };

=head1 DESCRIPTION

This module provides a C<gather> keyword that allows lists to be constructed
procedurally, without the need for a temporary variable.

Within the block controlled by a C<gather> any call to C<take> pushes that
call's argument list to an implicitly created array.

C<gather> returns the list of values taken during its block's execution.

=head1 EXAMPLES

  my @interesting_child_nodes = gather for my $n (@nodes) {
      take $n->all_children
          if $n->is_interesting;
  };

  my @last_10_events = gather {
      while ($log->has_event) {
          take $log->next_event;
      }

      shift gathered while gathered > 10;
  };

  my @search_results = gather {
      $user_interface->register_status_callback(sub {
          sprintf "Searching... Found %d matches so far", scalar gathered;
      });

      wait_for_search_results(sub {
          my ($result) = @_;
          take $result;
      }, @search_terms);

      $user_interface->register_status_callback(sub {
          sprintf "Found a total of %d", scalar gathered;
      });
  };

  my @leaf_nodes = gather {
      $graph->visit_all_nodes_recursively(sub {
          my ($node) = @_;
          take $node if $node->is_leaf;
      });
  };

=func gather

  gather { ... }
  gather({ ... })
  gather STMT

Executes the block it has been provided with, collecting all arguments passed to
C<take> calls within it. After execution, the list of values collected is
returned.

Note that block C<gather> executes is equivalent to a C<do BLOCK>. It is neither
a code nor a loop. Loop control keywords, such as C<next> and C<last>, as well
as C<return> will behave accordingly.

Parens around the C<gather> block are optional.

=func take

  take LIST

Collects a C<LIST> of values within the C<gather> block it has been compiled in.

C<take> returns all its arguments.

C<take> calls outside of the lexical scope of a C<gather> block are compile time
errors. Calling C<take> is only legal within the dynamic scope its associated
C<gather> block.

=func gathered

  gathered

Returns the list of items collected so far during the execution of a C<gather>
block.

C<gathered> calls outside of the lexical scope of a C<gather> block are compile
time errors. Calling C<gathered> outside of the dynamic scope of its associated
C<gather> block is legal.

=head1 SEE ALSO

=for :list
= L<Syntax::Keyword::Gather>
A non-lexical gather/take implementation that's otherwise very similar to this one
= L<Perl6::GatherTake>
An experimental implementation of a lazily evaluating gather/take
= L<Perl6::Take>
A very simple gather/take implementation without lexical scoping
= L<Perl6::Gather>
Like L<Syntax::Keyword::Gather>, but reliant on L<Perl6::Export>
= L<List::Gen>
A comprehensive suit list generation functions featuring a non-lexical gather/take

=head1 ACKNOWLEDGEMENTS

=for :list
* Andrew Main (Zefram) E<lt>zefram@fysh.orgE<gt>
for providing his input in both the design and implementation of this module,
and writing much of the infrastructure that made this module possible in the
first place
* Arthur Axel "fREW" Schmidt E<lt>frioux+cpan@gmail.comE<gt>
for his input on various aspects of this module as well as the many tests of his
L<Syntax::Keyword::Gather> module that this module shamelessly stole
* Dave (autarch) Rolsky <autarch@urth.org> and Jesse (doy) Luehrs E<lt>doy@tozt.netE<gt>
for helping to improve both documentation and test coverage

=cut

1;
