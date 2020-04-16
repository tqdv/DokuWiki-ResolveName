use DokuWiki::PageLink;
use DokuWiki::Utils;
use DokuWiki::Config;
use DokuWiki::PageName::Config;
use DokuWiki::PageName::Can;
use DokuWiki::Operators;

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
#| A bit redundant with $!app, but it allows not initializing $!app
has Can::PageName::Config $.config = DokuWiki::PageName::Config.new; #= DokuWiki config object

=head2 CONSTRUCTORS

=para
The :$config named argument is the application configuration object.
IDEA: make it so that you only need to supply the minimum configuration.

#| Creates a PageName object from a list of parts
multi method new (@parts is copy, :$config, :$app) {
	my $conf := $config // $app.?config // DokuWiki::PageName::Config.new;
	my $is-namespace-page = @parts[*-1] eq '' // False;

	# In this order.
	@parts .= &collapse-dots;
	@parts .= map: { colon-normalize($_) || Slip.new };
	my $name =
		($conf.startpage if $is-namespace-page)
		// @parts.pop
		// $conf.startpage; #= if @parts is empty

	self.bless: namespaces => @parts, :$name, config => $conf, |with-val :$app
}

#| Creates a PageName object from a link, assuming it's absolute
multi method new (DokuWiki::PageLink $link, :$config) {
	self.new: ($link.parts), |with-val :$config
}

#| Creates a PageName object from a PageLink string
multi method new (Str $string, :$config) {
	#| A page name is the same as a link, we just always consider it to start at root
	#| Since the string might be in the form of C<..link> or C<.link>, we let PageLink split that for us
	self.new: DokuWiki::PageLink.new($string), |with-val :$config
}

=head2 CONVERSIONS

method Str { self.gist }

method gist { ':' ~ (|@!namespaces, $!name).join(':') }

#| Make sure that array attributes are cloned correctly
method clone (--> DokuWiki::PageName) {
	self.bless:
		namespaces => @!namespaces.clone,
		|with-val config => $!config.clone,
		:$!name,
		|with-val app => $!app.clone
}

=head2 METHODS

=head3 .resolve-name

multi method resolve-name (DokuWiki::PageLink $link --> DokuWiki::PageName) {
	if $link.is-empty {
		return self.clone;
	} elsif $link.is-absolute {
		return self.new: $link, :$!config
	} else {
		# Otherwise, handle relative link
		my @parts = |@!namespaces, |$link.parts;

		my $is-namespace-link = @parts[*-1] eq '' // False;
		@parts .= &collapse-dots; #= Before resolve-namespace-page but after is-namespace-link
		@parts .= map: { colon-normalize($_) || Slip.new };

		my $name =
			(if $is-namespace-link { self.resolve-namespace-page: @parts, :$!config })
			// @parts.pop
			// $!config.startpage; #= If we get an empty list, which is surprising

		$name .= &colon-normalize;

		# Check -s variant of pagename if we didn't resolve it
		if !$is-namespace-link && $!config.autoplural {
			if !$!app.?page-exists(|@parts, $name) {
				my $alt = $name ~~ /s$/ ?? $name.substr(0, *-1) !! $name ~ 's';
				$name = $alt if $!app.?page-exists(|@parts, $alt);
			}
		}

		return self.new: namespaces => @parts, :$name, :$!config, :$!app
	}
}

multi method resolve-name (Str $target --> DokuWiki::PageName) {
	self.resolve-name: DokuWiki::PageLink.new($target)
}

#| Resolve a link that looks like `playground:` aka. a namespace link. Returns the pagename
multi method resolve-namespace-page (DokuWiki::PageName:D: @ns --> Str) {
	# TOCHECK: FIXME: infinite loop
	self.resolve-namespace-page: @ns, :$!config
}

#| Same as resolve-namespace-page, but without accessing attributes
multi method resolve-namespace-page (DokuWiki::PageName:_: @ns, :$config!, :$app --> Str) {
	sub if-page-exists ($name) {
		$name if $app.?page-exists(|@ns, $name)
	}

	my Str $name =
		if-page-exists($config.startpage) #= namespace: -> namespace:start
		#| This will fail if @parts == 0, but that's OK
		// if-page-exists(@ns[*-1]) #= namespace: -> namespace:namespace
		// if-page-exists(Slip.new) #= namespace: -> namespace
		// $config.startpage;

	return $name;
}