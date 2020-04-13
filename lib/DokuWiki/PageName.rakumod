use DokuWiki::PageLink;
use DokuWiki::Utils;

our $START_PAGE = 'start';

#| Represents an actual page, based on its absolute name
unit class DokuWiki::PageName;

=begin SYNOPSIS
use DokuWiki::PageName;

my DokuWiki::PageName $page .= new('current:page');
$page.resolve-name('.link:target');
#> Returns a DokuWiki::PageName object that stringifies to a canonical pagename
=end SYNOPSIS

has Str @.namespaces; #= parent namespaces
has Str $.name;

has Str $.start; #= DokuWiki C<startpage> option

=head2 CONSTRUCTORS

=para
The :$start named argument is the name of the default namespace start page.

#| Creates a PageName object from a list of parts
multi method new (@bits, :$start is copy) {
	$start //= 'start';

	my @parts = @bits;
	#| A trailing colon means the start page (eg. C<:youtube:channel:> -> C<:youtube:channel:start>)
	if @parts[*-1] eq '' {
		@parts[*-1] = $start;
	}
	collapse-dots(@parts);
	@parts .= map: { colon-normalize($_) };

	my $pagename = @parts.pop // $start;

	return DokuWiki::PageName.new: namespaces => @parts, name => $pagename, :$start;
}

#| Creates a PageName object from a link, assuming it's absolute
multi method new (DokuWiki::PageLink $link, :$start) {
	self.new: $link.parts, :$start
}

multi method new (Str $string, :$start) {
	#| A page name is the same as a link, we just always consider it to start at root
	#| Since the string might be in the form of C<..link> or C<.link>, we let PageLink split that for us
	self.new: DokuWiki::PageLink.new($string), :$start
}

=head2 CONVERSIONS

method Str { self.gist }

method gist { ':' ~ (|@!namespaces, $!name).join(':') }

=head2 METHODS

=head3 .resolve-name
You can pass a named parameter C<start> which is the value of DokuWiki's C<startpage> option. It defaults to the DokuWiki default of C<start>.

multi method resolve-name (DokuWiki::PageLink $link, :$start = $!start --> DokuWiki::PageName) {
	if $link.is-absolute {
		return self.new: $link, :$start
	} else {
		# Otherwise, handle relative link
		return self.new: (|@!namespaces, |$link.parts), :$start
	}
}

multi method resolve-name (Str $target, :$start --> DokuWiki::PageName) {
	self.resolve-name: DokuWiki::PageLink.new($target), :$start
}