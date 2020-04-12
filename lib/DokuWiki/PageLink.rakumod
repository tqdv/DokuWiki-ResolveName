#|[ Represents a wiki page link, be it relative or absolute as simple list
For example: same_ns, ..:parentpage, :absolute:page:name
See L<https://www.dokuwiki.org/pagename>
]
unit class DokuWiki::PageLink;

has @.parts;

=head2 CONSTRUCTOR

#| Create an object from the string representation
multi method new (Str $string) {
	my $s = $string;

	# Starts with . or .. -> Add a colon if needed
	if $s ~~ /^ ('.' ** 1..2) <!before '.'|':'|$ >/ {
		my $prefix = $0;
		$s ~~ s/^ $prefix /$prefix:/;
	}

	self.new: parts => $s.split(':');
}

=head2 CONVERSIONS

method Str { self.gist }

method gist { @!parts.join(':') }

=head2 METHODS

method is-absolute (--> Bool) { ! self.is-relative }

method is-relative (--> Bool) {
	(@!parts.head // '') eq '.'|'..' || @!parts.elems == 1
}