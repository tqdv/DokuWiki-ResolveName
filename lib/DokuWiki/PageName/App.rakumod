use DokuWiki::PageName::Can;
use DokuWiki::PageName::Config;
use DokuWiki::PageName;

=head2 DokuWiki::PageName::App
A barebones app for DokuWiki::PageName processing

unit class DokuWiki::PageName::App does Can::PageName::App;

has DokuWiki::PageName::Config $.config;
has SetHash $.pages;

=head2 CONSTRUCTORS

multi method new (:@pages!) {
	self.bless: pages => @pages.map({ DokuWiki::PageName.new($_).Str }).SetHash
}

=head2 METHODS

multi method page-exists (+@parts --> Bool) {
	self.page-exists: DokuWiki::PageName.new(@parts, app => self)
}

multi method page-exists (DokuWiki::PageName $page --> Bool) {
	$page.Str ∈ $!pages
}

#| Add pages to the set of known pages
method add-page (+@pages) {
	$!pages.{$_.Str}++ for @pages
}

#| Creates a new pagename with this app context
method new-pagename (|c --> DokuWiki::PageName) {
	my $ret = DokuWiki::PageName.new: |c, :$!config, app => self;
	self.add-page: $ret;
	return $ret;
}