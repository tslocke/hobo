# Add a footer to every page

Originally written by Tom on 2008-11-04.

Nice easy one here. In application.dryml:

    <extend tag="page">
      <old-page merge>
        <footer: param>
          ... your custom footer here ...
        </footer:>
      </old-page>
    </extend>
{: .dryml}

Note that cusomtising the `<page>` tag like this is common for all sorts of reaons. If you already have an `<extend tag="page">` in application.dryml, you probably want to just add that footer parameter to it, rather than extending page again (although that is allowed).

