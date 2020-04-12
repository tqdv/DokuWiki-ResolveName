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

=head2 CONSTRUCTORS

#| Creates a PageName object from a list of parts
multi method new (@bits) {
	my @parts = @bits;

	#| A trailing colon (as in C<:youtube:channel:>) means C<:youtube:channel:start>
	if @parts[*-1] eq '' {
		@parts[*-1] = $START_PAGE;
	}
	collapse-dots(@parts);
	@parts .= map: { colon-normalize($_) };

	my $pagename = @parts.pop // $START_PAGE;

	my $page = DokuWiki::PageName.new: namespaces => @parts, name => $pagename;
	# FIXME: $page.normalize;

	return $page;
}

multi method new (Str $string) {
	#| A page name is the same as a link, we just always consider it to start at root
	#| Since the string might be in the form of C<..link> or C<.link>, we let PageLink split that for us
	self.new: DokuWiki::PageLink.new($string)
}

#| Creates a PageName object from a link, assuming it's absolute
multi method new (DokuWiki::PageLink $link) {
	self.new: $link.parts
}

=head2 CONVERSIONS

method Str { self.gist }

method gist { ':' ~ (|@!namespaces, $!name).join(':') }

=head2 METHODS

multi method resolve-name (DokuWiki::PageLink $link --> DokuWiki::PageName) {
	if $link.is-absolute {
		return self.new: $link
	} else {
		# Otherwise, handle relative link
		return self.new: (|@!namespaces, |$link.parts)
	}
}

multi method resolve-name (Str $target --> DokuWiki::PageName) {
	self.resolve-name: DokuWiki::PageLink.new($target)
}