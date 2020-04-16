use DokuWiki::Config;
use DokuWiki::PageName;
use DokuWiki::PageName::Can;

#|[ This class represents the state of the application.
It may perform dependency injection
]
unit class DokuWiki::App does Can::PageName::App;

has DokuWiki::Config $.config .= new;

=head2 ATTRIBUTES

has SetHash[Str] $pages;

=head2 METHODS

method new-pagename (|c --> DokuWiki::PageName) {
	DokuWiki::PageName.new(|c, :$!config)
}

method page-exists (@parts) {

}