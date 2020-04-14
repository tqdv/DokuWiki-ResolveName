use DokuWiki::PageName;

unit module DokuWiki::ResolveName;

=begin SYNOPSIS
use DokuWiki::ResolveName;

resolve-name('current:page', '.link:target')
#> Returns an object that stringifies to a canonical pagename
=end SYNOPSIS

=head2 FUNCTIONS

=head3 resolve-name
You can pass a named parameter C<startpage> which is the value of DokuWiki's C<startpage> option. It defaults to the DokuWiki default of C<start>.

#| Functional interface
multi sub resolve-name (Str $from, $target, *%h --> DokuWiki::PageName) is export {
	my DokuWiki::PageName::Config $config .= new: |%h;
	resolve-name DokuWiki::PageName.new($from, :$config), $target
}

multi sub resolve-name (DokuWiki::PageName $from, $target --> DokuWiki::PageName) is export {
	$from.resolve-name: $target
}