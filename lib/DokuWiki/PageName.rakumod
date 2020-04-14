use DokuWiki::PageLink;
use DokuWiki::Utils;
use DokuWiki::Config;
use DokuWiki::Config::PageName;

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

has Can::PageName::Config $.config = DokuWiki::PageName::Config.new; #= DokuWiki config object

=head2 CONSTRUCTORS

=para
The :$config named argument is the application configuration object.
IDEA: make it so that you only need to supply the minimum configuration.

#| Creates a PageName object from a list of parts
multi method new (@bits, :$config is copy) {
	$config //= DokuWiki::Config.new;

	my @parts = @bits;
	# FIXME: it's more complex that this
	#| A trailing colon means the start page (eg. C<:youtube:channel:> -> C<:youtube:channel:start>)
	if @parts[*-1] eq '' {
		@parts[*-1] = $config.startpage;
	}
	collapse-dots(@parts);
	@parts .= map: { colon-normalize($_) };

	my $pagename = @parts.pop // $config.startpage;

	return DokuWiki::PageName.new: namespaces => @parts, name => $pagename, :$config;
}

#| Creates a PageName object from a link, assuming it's absolute
multi method new (DokuWiki::PageLink $link, :$config) {
	self.new: ($link.parts), :$config
}

#| Creates a PageName object from a PageLink string
multi method new (Str $string, :$config) {
	#| A page name is the same as a link, we just always consider it to start at root
	#| Since the string might be in the form of C<..link> or C<.link>, we let PageLink split that for us
	self.new: DokuWiki::PageLink.new($string), :$config
}

=head2 CONVERSIONS

method Str { self.gist }

method gist { ':' ~ (|@!namespaces, $!name).join(':') }

=head2 METHODS

=head3 .resolve-name

multi method resolve-name (DokuWiki::PageLink $link --> DokuWiki::PageName) {
	if $link.is-absolute {
		return self.new: $link, :$!config
	} else {
		# Otherwise, handle relative link
		return self.new: (|@!namespaces, |$link.parts), :$!config
	}
}

multi method resolve-name (Str $target --> DokuWiki::PageName) {
	self.resolve-name: DokuWiki::PageLink.new($target)
}