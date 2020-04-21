use DokuWiki::PageName;
use DokuWiki::PageName::App;
use DokuWiki::Operators;

unit module DokuWiki::ResolveName;

=begin SYNOPSIS
use DokuWiki::ResolveName;

# Returns an object that stringifies to a canonical pagename
resolve-name('current:page', '.link:target') #> ':current:link:target'

# You can pass optional named arguments
resolve-name('playground:playground', '.:',
    pages => ('start', 'playground', 'playground:playground'),
    startpage => 'index'
) #> ':playground'
=end SYNOPSIS

=head2 FUNCTIONS

=head3 resolve-name

=begin para
Optional named arguments:
- C<startpage> corresponds to DokuWiki's startpage config option.
- C<pages> is the list of existing pages. It is used for namespace link resolution
- C<sepchar> is the character used to replace invalid characters (refer to DokuWiki's docs)
- C<useslash> is the option whether to allow slashes as valid namespace separators
- C<autoplural> is the option that checks whether a -s variant of a page exists when you link to it
=end para

#| Functional interface
multi sub resolve-name (Str $from, $target, *%h --> DokuWiki::PageName) is export {
	my $app;
	with %h<pages> {
		$app = DokuWiki::PageName::App.new: pages => %h<pages>:delete.List;
	}

	my DokuWiki::PageName::Config $config .= new: |%h;
	resolve-name DokuWiki::PageName.new($from, :$config, |with-val :$app), $target,
}

multi sub resolve-name (DokuWiki::PageName $from, $target --> DokuWiki::PageName) is export {
	$from.resolve-name: $target
}