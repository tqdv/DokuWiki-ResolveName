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

## Caveats

* Does not support links to sections (eg. `minecraft:carrot#usage`).
* Does not handle accented characters the way DokuWiki does with the [deaccent option](https://www.dokuwiki.org/config:deaccent). It doesn't convert accented characters to an ASCII equivalent. This might cause bugs when a same character is encoded in different ways.
* Does not support a custom [startpage value](https://www.dokuwiki.org/config:startpage), which is the default page to link to in a namespace (by default, `start`).

## See also

The reference pages:
* <https://www.dokuwiki.org/namespaces>
* <https://www.dokuwiki.org/pagename>

## Credits

Written by Tilwa Qendov.
Licensed under [The Artistic License 2.0](LICENSE).