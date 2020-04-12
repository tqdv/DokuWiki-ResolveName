use DokuWiki::PageName;

unit module DokuWiki::ResolveName;

=begin SYNOPSIS
use DokuWiki::ResolveName;

resolve-name('current:page', '.link:target')
#> Returns an object that stringifies to a canonical pagename
=end SYNOPSIS

=head2 FUNCTIONS

#| Functional interface
multi sub resolve-name (Str $from, $target --> DokuWiki::PageName) is export {
	resolve-name DokuWiki::PageName.new($from), $target
}

multi sub resolve-name (DokuWiki::PageName $from, $target --> DokuWiki::PageName) is export {
	$from.resolve-name: $target
}