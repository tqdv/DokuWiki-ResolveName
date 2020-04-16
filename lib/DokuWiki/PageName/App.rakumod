use DokuWiki::PageName::Can;
use DokuWiki::PageName::Config;

=head2 DokuWiki::PageName::App
A barebones app for DokuWiki::PageName processing

unit class DokuWiki::PageName::App does Can::PageName::App;

has DokuWiki::PageName::Config $.config;
has SetHash[Str] $!pages;

multi method page-exists (@parts --> Bool) {
	self.page-exists: DokuWiki::PageName.new(@parts, app => self)
}

multi method page-exists (DokuWiki::PageName $page --> Bool) {
	$page.Str ∈ $!pages
}
