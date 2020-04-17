# DokuWiki::ResolveName

Resolve relative and absolute DokuWiki page links.

## Synopsis

    use DokuWiki::ResolveName;
    
    resolve-name('current:page', '.link:target')
    #> Returns a DokuWiki::PageName object that stringifies to a canonical pagename
    
    # ===============================
    # Alternatively, the OO-interface
    # ===============================
    
    use DokuWiki::PageName;
    
    my DokuWiki::PageName $page .= new('current:page');
    $page.resolve-name('.link:target');
    #> Same as earlier

## Description

This module provides a functional and object-oriented interface to resolving DokuWiki link page targets. The functional interface uses the OO one under the hood.

**WARN:** Resolving namespace links (those that end in a colon eg. `namespace:`) requires knowledge of some other existing pages, notably `namespace:namespace` and `namespace`.

* Supports custom [startpage values](https://www.dokuwiki.org/config:startpage), which is the default page to link to in a namespace (by default, `start`).

## Roadmap

* Support DokuWiki options `useslash`, `sepchar`
* Remember to lowercase the pagename, and collapse sepchars, semi-colons are valid separators (cf. <https://xref.dokuwiki.org/reference/dokuwiki/_functions/cleanid.html>)

## Caveats

* Does not support links to sections (eg. `minecraft:carrot#usage`).
* Does not handle accented characters the way DokuWiki does with the [deaccent option](https://www.dokuwiki.org/config:deaccent). It doesn't convert accented characters to an ASCII equivalent. This might cause bugs when a same character is encoded in different ways.

## See also

The reference pages:
* <https://www.dokuwiki.org/namespaces>
* <https://www.dokuwiki.org/pagename>
* The [resolve_pageid function in pageutils.php](https://xref.dokuwiki.org/reference/dokuwiki/_functions/resolve_pageid.html) on DokuWiki's XRef

## Credits

Written by Tilwa Qendov.
Licensed under [The Artistic License 2.0](LICENSE).