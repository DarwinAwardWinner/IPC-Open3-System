use 5.10.0;
use warnings;
use strict;

package IPC::Open3::System;
# ABSTRACT: Provide an C<open3> function with the same syntax as C<system>

use Any::Moose;
use namespace::autoclean;

use Carp;
use utf8;
use autodie qw( :all );
use IPC::Open3 ();
use String::ShellQuote;
use Symbol;
use List::Flatten::Recursive;

use base 'Exporter::Simple';
sub open3 : Exportable {
    return IPC::Open3::System->new(@_);
}

around BUILDARGS => sub {
    my $orig = shift;
    my $class = shift;

    my($child_in, $child_out, $child_err);
    $child_err = Symbol::gensym();
    my @command = List::Flatten::Recursive::flat(@_);
    my $pid = IPC::Open3::open3($child_in, $child_out, $child_err, @command);

    return $class->$orig(
        command => [ @command ],
        pid => $pid,
        in => $child_in,
        out => $child_out,
        err => $child_err,
    );
};

has 'command' => (
    is => 'ro',
    isa => 'ArrayRef',
);

has 'pid' => (
    is => 'ro',
    isa => 'Int'
);

has 'in' => (
    is => 'ro',
    isa => 'FileHandle'
);

has 'out' => (
    is => 'ro',
    isa => 'FileHandle'
);

has 'err' => (
    is => 'ro',
    isa => 'FileHandle'
);

__PACKAGE__->meta->make_immutable;

1; # Magic true value required at end of module
__END__

=head1 SYNOPSIS

    use 5.10.0; # For "say" function
    use IPC::Open3::System qw( open3 );

    my $command = "cat";
    my $proc = open3($command);

    # Info about the process
    say "Started command: ", join " ", @{$proc->command};
    say "Subprocess PID: $proc->pid";

    # Send some input to the process:
    print {$proc->in} "INPUT DATA";

    # Read output
    my @subprocess_output = readline $proc->out;
    my @subprocess_errors = readline $proc->err;

=for author to fill in:
    Brief code example(s) here showing commonest usage(s).
    This section will be as far as many users bother reading
    so make it as educational and exeplary as possible.


=head1 DESCRIPTION

=for author to fill in:
    Write a full description of the module and its features here.
    Use subsections (=head2, =head3) as appropriate.

=head1 INTERFACE

=head2 open3

    This is simply a shortcut for B<IPC::Open3::System->new>. The
    syntax is similar to the builtin B<system>. It creates and returns
    a "process" object corresponding to the execution of the command
    you specified. This object is simply a wrapper for the following fields:

=head2 new

    The OO constructor for IPC::Open3::System. Pass it the same arguments that you would pass to the builtin B<system>

=head1 FIELDS

An IPC::Open3::System object has the following fields. Each can be accessed by a method of the same name (see SYNOPSIS for examples of each).

=over

=item command

The command that was provided to the constructor.

=item pid

The PID of the subprocess that was started.

=item in

=item out

=item err

These three fields correspond, respectively, to the child process's STDIN, STDOUT, and STDERR. Note that the parent process (i.e. your perl script) will be *writing* to B<in> and *reading* from B<out> and B<err>.

=back

=head1 DIAGNOSTICS

=for author to fill in:
    List every single error and warning message that the module can
    generate (even the ones that will "never happen"), with a full
    explanation of each problem, one or more likely causes, and any
    suggested remedies.

=over

=item C<< Error message here, perhaps with %s placeholders >>

[Description of error here]

=item C<< Another error message here >>

[Description of error here]

[Et cetera, et cetera]

=back


=head1 DEPENDENCIES

=for author to fill in:
    A list of all the other modules that this module relies upon,
    including any restrictions on versions, and an indication whether
    the module is part of the standard Perl distribution, part of the
    module's distribution, or must be installed separately. ]

None.


=head1 INCOMPATIBILITIES

=for author to fill in:
    A list of any modules that this module cannot be used in conjunction
    with. This may be due to name conflicts in the interface, or
    competition for system or program resources, or due to internal
    limitations of Perl (for example, many modules that use source code
    filters are mutually incompatible).

None reported.

=head1 BUGS AND LIMITATIONS

=head2 Syntax-compatibility with builtin B<system>

For most inputs, B<open3> (and B<new>) should end up executing the
same command as perl's builtin B<system>. However, this is not
thoroughly tested. Test cases are appreciated.

=head2 Angle-operator syntax oddities

You have to read from a process object's filehandles using B<readline>
instead of the usual angle operators, because the right angle bracket
of the method call arrow ('->') confuses perl, which is already
looking for the end of the angle operator.

=head2 Naming

The name of this module stinks. I can't think of a more descriptive
name. Suggestions are welcome.

Please report any bugs or feature requests to
C<rct+perlbug@thompsonclan.org>.


=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
