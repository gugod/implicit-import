package implicit::import;
use v5.38;
use Keyword::Simple;
use PPR;
use B::Hooks::EndOfScope qw(on_scope_end);
my @originals;

BEGIN {
    require Exporter;
    push @originals, [
        "Exporter", \&Exporter::import, \&Exporter::unimport,
    ];
}

sub import {
}

sub unimport {
    my ($class) = @_;
    my ($caller) = caller;

    Keyword::Simple::define 'use', sub {
        my ($ref) = @_;
        substr($$ref, 0, 0) = "use";
        $$ref =~ s{\A ((?&PerlUseStatement)) $PPR::GRAMMAR}{}x;
        my $statement = $1
            or die "Unexpected token after `use`: $$ref";

        ## Copied from PPR, in order to add capturing groups.
        $statement =~ m{\A
            use (?>(?&PerlNWS))
            (?>
                (?<perl_version_number> (?&PerlVersionNumber))
            |
                (?<module_name> (?>(?&PerlQualifiedIdentifier)))
                (?: (?>(?&PerlNWS)) (?<module_version_number> (?&PerlVersionNumber))
                    (?! (?>(?&PerlOWS)) (?> (?&PerlInfixBinaryOperator) | (?&PerlComma) | \? ) )
                )?+
                (?<module_args>
                (?: (?>(?&PerlNWS)) (?&PerlPodSequence) )?+
                (?: (?>(?&PerlOWS)) (?&PerlExpression) )?+
                )
            )
            (?>(?&PerlOWSOrEND)) (?<end_of_statement> (?> ; | (?= \} | \z )))
            $PPR::GRAMMAR
        }x;

        my $replacement = "...";

        if ($+{module_name}) {
            if ( $+{module_args} eq '' ) {
                # case 1: C<use Foo;>
                # case 2: C<use Foo 1.23.4;>
                $replacement = "require " . $+{module_name} . "; ";
                if ( defined $+{module_version_number} ) {
                    $replacement .= $+{module_name} . "->VERSION(" . $+{module_version_number} . "); ";
                }
            } else {
                # case 3: C<use Foo 1.23.4 @args>
                # case 4: C<use Foo @args>
                $replacement = "require " . $+{module_name} . "; ";

                if ( defined $+{module_version_number} ) {
                    $replacement .=
                        $+{module_name} . "->VERSION(" . $+{module_version_number} . "); ";
                }

                $replacement .=
                        $+{module_name} . "->import(" . $+{module_args} . "); ";
            }
        }
        elsif (defined $+{perl_version_number}) {
            # case 5: C<use v5.36>
            $replacement = "require " . $+{perl_version_number} . ";" ;
        }
        else {
            die "Unrecognized statement: $statement;"
        }

        $replacement = "BEGIN { $replacement }" . $+{end_of_statement};

        say "Translate:\n  from: $statement\n    to: $replacement\n";

        substr($$ref, 0, 0) = $replacement;

        return;
    };
}

on_scope_end {
    Keyword::Simple::undefine 'use';
};
