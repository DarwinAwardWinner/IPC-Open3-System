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

=head1 DESCRIPTION

This is yet another module for running a program and communicating
with it. I couldn't find any modules out there with a sane interface
for running a subprocess and returning *all three* of its handles:
STDIN, STDOUT, and STDERR, so I wrote one.

=head1 INTERFACE

=head2 open3

    This is simply a shortcut for C<IPC::Open3::System->new>. The
    syntax is similar to Perl's builtin C<system>. It creates and
    returns a "process" object for the subprocess that it spawns. The
    object is simply a container for the subprocess's filehandles,
    which are describe below, under FIELDS.

=head2 new

    The OO constructor for IPC::Open3::System. Pass it the same
    arguments that you would pass to the builtin C<system>.

=head1 FIELDS

An IPC::Open3::System object has the following fields. Each can be
accessed by a method of the same name (see SYNOPSIS for examples of
each).

=over

=item command

The command that was provided to the constructor.

=item pid

The PID of the subprocess that was started.

=item in

=item out

=item err

These three fields correspond, respectively, to the child process's
STDIN, STDOUT, and STDERR. Note that the parent process (i.e. your
Perl script) will be *writing* to C<in> and *reading* from C<out> and
C<err>.

=back

=head1 DEPENDENCIES

=over

=item autodie

=item IPC::Open3

This module is really a wrapper around C<IPC::Open3>.

=item String::ShellQuote;

=item List::Flatten::Recursive

This is my own module. Not yet on CPAN.

=back

=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

=head2 Syntax-compatibility with builtin system

For most inputs, C<open3> (and C<new>) should end up executing the
same command as Perl's builtin C<system>. However, this is not
thoroughly tested. Test cases are appreciated.

=head2 Angle-operator syntax oddities

You have to read from a process object's filehandles using C<readline>
instead of the usual angle operators, because you can't put
complicated things inside Perl's angle operator. Alternatively, you
can assign the filehandles to variables and then use those variables
as normal:

    my $out = $proc->out;
    my $output = <$out>;

=head2 Naming

The name of this module stinks. I can't think of a more descriptive
name. Suggestions are welcome.

Please report any bugs or feature requests to
C<rct+perlbug@thompsonclan.org>.
