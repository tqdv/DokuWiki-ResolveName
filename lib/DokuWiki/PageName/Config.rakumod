use DokuWiki::PageName::Can;

# This is not a module because I can't seem to exporting
# Nested classes correctly
# An old comment explaining my struggles:
# `is export` currently doesn't change behaviour, but I think it's a bug
# similar to https://github.com/rakudo/rakudo/issues/1458
# It is exported automatically since the DokuWiki package exists
# Also, `is export` would export it as the 'Config' symbol and not the nested identifier

=para
Note that this module exports C<DokuWiki::PageName::Config> and C<Can::PageName::Config>
Maybe this could be fixed in the META6, but I'm not sure

=head2 DokuWiki::PageName::Config and Can::PageName::Config
Type object and check for the $!config attribute

class DokuWiki::PageName::Config does Can::PageName::Config {
	has Str $.startpage = 'start';
	has Str $.sepchar = '_';
	has Bool $.autoplural = False;
	has Bool $.useslash = False;
}
