=para
This file defines Roles/Interfaces used by classes related to L<DokuWiki::PageName>.
They exist to enforce type checks or resolve circular dependencies.

role Can::PageName::App {
	method page-exists { 1; !!! } #= HACK: if it were a stub, it wouldn't clone correctly
}

sub can-pagename-config ($v --> Bool) is export(:func) {
	qw<startpage sepchar autoplural useslash> ⊆ $v.^methods».name
}

# Do not try to export it, as it will export it as the 'Config' symbol
#| Similar to a Haskell type class (?), this checks that the object has the right methods
subset Can::PageName::Config where can-pagename-config($_);