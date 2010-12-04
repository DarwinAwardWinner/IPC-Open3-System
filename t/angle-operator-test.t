#!perl

use 5.10.0;
use Test::More;
use Test::Differences;
use File::Which;
use Scalar::Util qw( openhandle looks_like_number );
use IPC::Open3::System qw( open3 );
my $perlbin = which 'perl';

if ($perlbin) {
    # Perl command to duplicate STDIN to both STDOUT and STDERR.
    # Should work anywhere perl does (cross fingers for
    # cross-platform)
    my @command = ( $perlbin, '-lape', 'print STDERR $_' );

    # Create a proc
    my $proc = open3(@command);
    ok($proc, 'create an object');

    # Validate attrs
    eq_or_diff($proc->command, \@command, 'correct command');
    ok(looks_like_number($proc->pid), 'valid pid');
    my $in_handle = $proc->in;
    my $out_handle = $proc->out;
    my $err_handle = $proc->err;
    ok(openhandle($in_handle), 'valid input handle after assignment');
    ok(openhandle($out_handle), 'valid output handle after assignment');
    ok(openhandle($err_handle), 'valid error handle after assignment');

    # Write something to stdin, then read it from stdout and stderr
    # using angle operator.
    my $message = "hello";
    ok((say $in_handle $message), 'print message to subprocess STDIN');
    ok(close $in_handle, 'close subprocess STDIN');
    chomp(my $message_out = <$out_handle>);
    chomp(my $message_err = <$err_handle>);
    eq_or_diff($message_out, $message, 'read message from STDOUT');
    eq_or_diff($message_err, $message, 'read message from STDERR');



    done_testing();
}
else {
    plan skip_all => "Cannot find perl binary";
}
