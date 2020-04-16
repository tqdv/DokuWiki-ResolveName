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

#| Remove illegal characters in a page name from a string
sub colon-normalize (Str $string is copy) is export {
	# Trim illegal characters
	$string ~~ s/^ <[ . \- _ ]>*  //;
	$string ~~ s/  <[ . \- _ ]>* $//;

	# Replace disallowed characters with underscores
	$string ~~ s:g/ <-[ . \- _ ] - [a..z A..Z] - [0..9]> /_/;

	return $string;
}

sub EXPORT {
	%(
		:&pop-null,
		:&collapse-dots,
		:&ltrim-colon,
		:&colon-normalize,
	)
}