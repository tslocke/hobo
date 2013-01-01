# How do I get rid of `WARN  Could not determine content-length of response body. Set content-length of the response or set Response#chunked = true`

This one seems to be an issue with WEBrick and Ruby 1.9.3.

I got rid of it by converting to using
[Thin](http://code.macournoyer.com/thin/) instead of WEBrick. Seems
like a snappier webserver anyway.

BTW: Since I am on Windows installing Thin may be difficult, due to
its dependency on eventmachine. However, I followed [this
tip](http://stackoverflow.com/questions/3649252/cannot-install-thin-on-windows#comment10860757_4200880)
on a stackoverflow answer, which worked for me (I used version
1.0.0.rc.4). Future releases of eventmachine may have fixed this
problem though.

