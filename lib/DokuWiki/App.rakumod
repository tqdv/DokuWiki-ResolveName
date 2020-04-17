use DokuWiki::Config;
use DokuWiki::PageName;
use DokuWiki::PageName::Can;

#|[ This class represents the state of the application.
It may perform dependency injection ]
unit class DokuWiki::App does Can::PageName::App;

=head2 ATTRIBUTES

has DokuWiki::Config $.config = DokuWiki::Config.new;
has SetHash $.pages = SetHash.new;

=head2 METHODS

multi method page-exists (+@parts --> Bool) {
	self.page-exists: DokuWiki::PageName.new(@parts, :$!config, app => self)
}

multi method page-exists (DokuWiki::PageName $page --> Bool) {
	$page.Str ∈ $!pages
}

#| Add page to the set of known pages. Does not create it.
method add-page (+@pages) {
	$!pages.{$_.Str}++ for @pages
}

#| Creates a new pagename, and adds it to the set of known pages
method new-pagename (|c --> DokuWiki::PageName) {
	my $ret = DokuWiki::PageName.new: |c, :$!config, app => self;
	self.add-page: $ret;
	return $ret;
}