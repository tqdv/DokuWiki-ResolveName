#|[ Represents a wiki page link, be it relative or absolute as simple list
For example: same_ns, ..:parentpage, :absolute:page:name
See L<https://www.dokuwiki.org/pagename>
]
unit class DokuWiki::PageLink;

has @.parts;

=head2 CONSTRUCTOR

#| Create an object from the string representation
multi method new (Str $string is copy) {
	# Starts with . or .. -> Add a colon if needed
	if $string ~~ /^ ('.' ** 1..2) <!before '.'|':'|$ >/ {
		my $prefix = $0;
		$string ~~ s/^ $prefix /$prefix:/;
	}

	self.new: parts => $string.split(':');
}

=head2 CONVERSIONS

method Str { self.gist }

method gist { @!parts.join(':') }

=head2 METHODS

method is-empty (--> Bool) { @.parts eqv [''] }

method is-absolute (--> Bool) { ! self.is-relative }

method is-relative (--> Bool) {
	(@!parts[0] // '') eq '.'|'..' || @!parts.elems == 1
}