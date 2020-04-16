unit class DokuWiki::Config;

has Str $.startpage = 'start'; #= namespace start page
has Str $.sepchar = '_'; #= Invalid character replacement character
has Bool $.autoplural = False; #= tries to find "plural" forms for links
has Bool $.useslash = False; #= use / for namespace separation