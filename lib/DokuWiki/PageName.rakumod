use DokuWiki::PageName::Can;
use DokuWiki::PageName::Config;
use DokuWiki::PageLink;

use DokuWiki::Utils;
use DokuWiki::Operators;
use DokuWiki::PageId;

=begin SYNOPSIS
use DokuWiki::PageName;

my DokuWiki::PageName $page .= new('current:page');
$page.resolve-name('.link:target');
#> Returns a DokuWiki::PageName object that stringifies to a canonical pagename
=end SYNOPSIS

#| Represents an actual page, based on its absolute name
unit class DokuWiki::PageName;

=head2 ATTRIBUTES

has Str @.namespaces; #= parent namespaces
has Str $.name = 'invalid'; #= This default should hopefully never happen

has Can::PageName::App $.app;
#| We store it because we need to supply it when we create a new pagename
#| A bit redundant with $!app, but it allows not initializing $!app
has Can::PageName::Config $.config = DokuWiki::PageName::Config.new; #= DokuWiki config object

=head2 CONSTRUCTORS

=begin para
The :$config named argument is the application configuration object.

We construct a PageName from a string based on L<https://xref.dokuwiki.org/reference/dokuwiki/_functions/getid.html>,
which is used to grab the C<?id=page:name> part of the url.
=end para

#| Creates a PageName object from a list of parts
multi method new (@parts is copy, :$config, :$app) {
	my $conf := $config // $app.?config // DokuWiki::PageName::Config.new;

	@parts = $conf.&clean-pageid(@parts);
	my $name = @parts.pop // $conf.startpage; #= if @parts is empty

	self.bless: namespaces => @parts, :$name, config => $conf, |with-val :$app
}

#| Creates a PageName object from a string.
multi method new (Str $string is copy, :$config, :$app) {
	my $conf := $config // $app.?config // DokuWiki::PageName::Config.new;

	$string .= trim;
	my @parts = $conf.&split-pageid($string);
	my $is-namespace-page = @parts[*-1] eq '';

	@parts = $conf.&clean-pageid(@parts);
	my $name =
		(if $is-namespace-page {
			self.resolve-namespace-page: @parts, config => $conf, |with-val :$app })
		// @parts.pop
		// $conf.startpage; #= if @parts is empty

	self.bless: namespaces => @parts, :$name, config => $conf, |with-val :$app
}

=head2 CONVERSIONS

method Str { self.gist }

method gist { ':' ~ (|@!namespaces, $!name).join(':') }

#| Make sure that array attributes are cloned correctly
method clone (--> DokuWiki::PageName) {
	nextwith namespaces => @!namespaces.clone
}

=head2 METHODS

=head3 .resolve-name

multi method resolve-name (DokuWiki::PageLink $link --> DokuWiki::PageName) {
	if $link.is-empty {
		return self.clone;
	}

	# Normalize @parts
	my @parts = |(@!namespaces if $link.is-relative), |$link.parts;
	@parts .= &collapse-dots; #= Before resolve-namespace-page but after is-namespace-link
	@parts = $!config.&clean-pageid(@parts);

	my $name =
		(if $link.is-namespace-link { self.resolve-namespace-page: @parts })
		// @parts.pop
		// $!config.startpage; #= If we get an empty list

	# Check -s variant of pagename if we didn't resolve it
	if !$link.is-namespace-link && $!config.autoplural {
		if not $!app.?page-exists(|@parts, $name) {
			my $alt = $name ~~ /s$/ ?? $name.substr(0, *-1) !! $name ~ 's';
			$name = $alt if $!app.?page-exists(|@parts, $alt);
		}
	}

	return self.new: namespaces => @parts, :$name, :$!config, :$!app;
}

multi method resolve-name (Str $target --> DokuWiki::PageName) {
	self.resolve-name: DokuWiki::PageLink.new($target, :$!config)
}

#| Resolve a link that looks like `playground:` aka. a namespace link. Returns the pagename. It can modify @ns if needed
multi method resolve-namespace-page (DokuWiki::PageName:D: @ns --> Str) {
	self.resolve-namespace-page: @ns, :$!config, :$!app
}

#| Same as resolve-namespace-page, but without accessing attributes. It can modify @ns if needed
multi method resolve-namespace-page (@ns, :$config!, :$app --> Str) {
	my Str $name;

	with $app {
		sub if-page-exists ($name) {
			$name if $app.page-exists(|@ns, $name)
		}

		# Try the following pages if they exist
		$name =
			if-page-exists($config.startpage)     #= namespace: -> namespace:start
			#| This will fail if @parts == 0, in a way that doesn't work with //, thus the try
			// (try { if-page-exists(@ns[*-1]) })   #= namespace: -> namespace:namespace
			// (@ns.pop if $app.page-exists(@ns)) #= namespace: -> namespace
			// Str; #= leave undefined
	}

	$name //= $config.startpage; #= default when pages don't exist
	return $name;
}