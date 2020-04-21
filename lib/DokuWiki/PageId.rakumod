use DokuWiki::PageName::Can;

unit module DokuWiki::PageId;

=head2 DESCRIPTION
This module provides a functional interface to create pageids.
They can be used as Can::PageName::Config methods with the `.&` call syntax

=begin para
A dirty pageid is one that hasn't been cleaned yet: it is not made of valid pageid parts
=end para

#| Grammar that defines our valid pageid character class
grammar G {
	token not-charclass { <-charclass> }
	token charclass { <[ . \- _ ] + [a..z A..Z] + [0..9]> }
}

subset SepChar of Str where $_ ~~ /^ <G::charclass> $/;

#| Remove illegal characters in a page name component
sub colon-normalize (Can::PageName::Config $config, $string is copy) is export {
	# Lowercase it
	$string .= lc;

	# Replace sequences of disallowed characters and $sepchar with a single $sepchar
	$string ~~ s:g/ [ <G::not-charclass> | $($config.sepchar) ] + /$($config.sepchar)/;

	# Trim illegal characters
	$string ~~ s/^ <[ . \- _ ]>*  //;
	$string ~~ s/  <[ . \- _ ]>* $//;

	return $string;
}

#| Splits a string into a dirty pageid array
multi sub split-pageid (Can::PageName::Config $config, $string) is export {
	$string.split($config.delim)
}

#| Remove invalid characters from each part and remove the empty ones
multi sub clean-pageid (Can::PageName::Config $config, @parts) is export {
	@parts.map: { $config.&colon-normalize($_) || Slip.new }
}

#| Creates a new pageid array from a string
sub new-pageid (Can::PageName::Config $config, $string is copy) is export {
	$string .= trim;
	my @parts = $config.&split-pageid($string);
	@parts = $config.&clean-pageid(@parts);
	return @parts;
}

=head2 SEE ALSO
L<https://xref.dokuwiki.org/reference/dokuwiki/nav.html?_functions/cleanid.html>