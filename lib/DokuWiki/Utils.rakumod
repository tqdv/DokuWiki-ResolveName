unit module DokuWiki::Utils;

#| Pops the array or returns Nil
sub pop-null (@arr) is export {
	@arr.pop // Nil
}

#| Given an array of strings, collapse .., ., and ε and return it
sub collapse-dots (@arr) is export {
	my @ret;

	for @arr -> $elt {
		if $elt eq '' { next }
		if $elt eq '.' { next }
		if $elt eq '..' { pop-null @ret; next }

		@ret.push: $elt;
	}

	return @ret;
}

#| Trims a single colon from the left of a string
sub ltrim-colon (Str $string --> Str) is export {
	S/^ \: // with $string;
}

sub EXPORT {
	%(
		:&pop-null,
		:&collapse-dots,
		:&ltrim-colon,
	)
}