use DokuWiki::PageName;
use DokuWiki::PageName::App;
use DokuWiki::Operators;

unit module DokuWiki::ResolveName;

=begin SYNOPSIS
use DokuWiki::ResolveName;

resolve-name('current:page', '.link:target')
#> Returns an object that stringifies to a canonical pagename
=end SYNOPSIS

=head2 FUNCTIONS

=head3 resolve-name
You can pass a named parameter C<startpage> which is the value of DokuWiki's C<startpage> option. It defaults to the DokuWiki default of C<start>.
The pages named array is the list of existing pages. It is used for namespace link resolution.

#| Functional interface
multi sub resolve-name (Str $from, $target, :@pages, *%h --> DokuWiki::PageName) is export {
	my $app;
	with @pages {
		$app = DokuWiki::PageName::App.new: :@pages;
	}

	my DokuWiki::PageName::Config $config .= new: |%h;
	resolve-name DokuWiki::PageName.new($from, :$config, |with-val :$app), $target,
}

multi sub resolve-name (DokuWiki::PageName $from, $target --> DokuWiki::PageName) is export {
	$from.resolve-name: $target
}