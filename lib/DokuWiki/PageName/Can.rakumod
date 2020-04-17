=para
This file defines Roles/Interfaces used by classes related to L<DokuWiki::PageName>.
They exist to enforce type checks or resolve circular dependencies.

role Can::PageName::App {
	method page-exists { ... }
	method add-page { ... }
	method new-pagename { ... }
}

# Do not try to export it, as it will export it as the 'Config' symbol
role Can::PageName::Config {
	method startpage { ... }
	method sepchar { ... }
	method autoplural { ... }
	method useslash { ... }
}