package t::Foo;
use Exporter qw(import);

our $VERSION = v1.23.4;
our @EXPORT = ("foo", "bar");

sub foo { "foo" }
sub bar { "bar" }
