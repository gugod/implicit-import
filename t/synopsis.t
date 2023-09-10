use v5.38;
use Test2::V0;

use FindBin qw($Bin);
use lib "$Bin/lib";

package t::ImplicitImport {
    use t::Foo;
    use Test2::V0;

    sub run {
        subtest __PACKAGE__, sub {
            is __PACKAGE__->can("foo"), T(), "foo() is imported";
            is __PACKAGE__->can("bar"), T(), "bar() is imported";
        };
    }
}

package t::ImplicitImportWithVersion {
    use t::Foo v1.23.4;
    use Test2::V0;

    sub run {
        subtest __PACKAGE__, sub {
            is __PACKAGE__->can("foo"), T(), "foo() is imported";
            is __PACKAGE__->can("bar"), T(), "bar() is imported";
        };
    }
}

package t::ExplicitImport {
    no implicit::import;
    use t::Foo qw(foo);
    use Test2::V0 qw(is D F subtest);

    sub run {
        subtest __PACKAGE__, sub {
            is __PACKAGE__->can("foo"), D(), "foo() is imported";
            is __PACKAGE__->can("bar"), F(), "bar() is not imported";
        }
    }
}

package t::ExplicitImportWithVersion {
    no implicit::import;
    use t::Foo v1.23.4 qw(foo);
    use Test2::V0 qw(is F D subtest);

    sub run {
        subtest __PACKAGE__, sub {
            is __PACKAGE__->can("foo"), D(), "foo() is imported";
            is __PACKAGE__->can("bar"), F(), "bar() is not imported";
        }
    }
}

package t::ExplicitNoImport {
    no implicit::import;
    use t::Foo;
    use Test2::V0 qw(is F subtest);

    sub run {
        subtest __PACKAGE__, sub {
            is __PACKAGE__->can("foo"), F(), "foo() is not imported";
            is __PACKAGE__->can("bar"), F(), "bar() is not imported";
        }
    }
}

package t::ExplicitNoImportWithVersion {
    no implicit::import;
    use t::Foo v1.23.4;
    use Test2::V0 qw(is F subtest);

    sub run {
        subtest __PACKAGE__, sub {
            is __PACKAGE__->can("foo"), F(), "foo() is not imported";
            is __PACKAGE__->can("bar"), F(), "bar() is not imported";
        }
    }
}

t::ImplicitImport->run;
t::ImplicitImportWithVersion->run;
t::ExplicitImport->run;
t::ExplicitImportWithVersion->run;
t::ExplicitNoImport->run;
t::ExplicitNoImportWithVersion->run;

done_testing;
