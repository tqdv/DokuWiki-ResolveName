use DokuWiki::PageId;

=head2 DESCRIPTION
Represents a wiki page link, be it relative or absolute as simple list
For example: same_ns, ..:parentpage, :absolute:page:name

=begin para
It corresponds to a dirty page id array and a boolean indicating whether it's a namespace link
Empty parts are removed, which is why is-relative works the way it does
=end para

unit class DokuWiki::PageLink;

has @.parts;
has Bool $.is-namespace-link;
has Bool $.is-relative;

=head2 CONSTRUCTOR

#| Create an object from the string representation
multi method new (Str $string is copy, :$config!) {
	# Starts with . or .. -> Add a colon if needed
	if $string ~~ /^ ('.' ** 1..2) <!before '.'|':'|$ >/ {
		my $prefix = $0;
		$string ~~ s/^ $prefix /$prefix:/;
	}

	my @parts = $config.&split-pageid($string);

	my $is-namespace-link = @parts[*-1] eq '' && @parts > 1;
	#| A link is absolute if it has at least a namespace separator (before we remove empty parts)
	my $is-relative = @parts.elems == 1 || so (@parts[0] eq '.'|'..') // False;

	@parts .= map: { $_ if $_ ne '' }; #= Remove empty

	self.bless: :@parts, :$is-namespace-link, :$is-relative
}

=head2 CONVERSIONS

method Str { self.gist }

method gist {
	(self.is-absolute ?? ':' !! '')
	~ @!parts.join(':')
	~ (self.is-namespace-link && @!parts.elems > 0 ?? ':' !! '')
}

=head2 METHODS

method is-empty (--> Bool) {
	@.parts.elems == 0 && !self.is-namespace-link && !self.is-absolute
}

method is-absolute (--> Bool) { not $!is-relative }

=head2 SEE ALSO
L<https://www.dokuwiki.org/pagename>