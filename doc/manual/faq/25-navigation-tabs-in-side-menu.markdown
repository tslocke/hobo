# Navigation Tabs in side-menu

Originally written by Bean on 2008-11-13.

Hello there. I learned the hard way that it's easier to do things right than twice.  So here goes: I'm looking for a way to avoid navigating to new pages and thus confusing the user.  I'd like to go from the login page to a "Workspace" with a side-menu and a main-content section.  By side-menu, I really mean tabs that have forms and lists on them for interacting with the backend models.  Right now, I've got way-too-much content in the side menu to make for good design.  What I really want is to hide and show the forms under a tab menu.  That way, the user can easily see where the features live, but aren't overwhelmed with too much at once.  If a user selects an item on the list, I want the content page to appear in the main section of the workspace.  Right now, selecting an item off the lists navigates to a whole new page.  

I've looked at Paoldona's rails-widgets plugin and it seems to provide this kind of functionality.  At the same time, I would be adding complexity to my app (additional CSS to style, for example).  There must be a good way to nest <`navigation`> and <`page`> tags in the side menu.  Also, there must be a DRYML way to redirect to the content <`section`> (or div, or partial, or whatever's best).  It seems like I need to redefine the <`cards`> in application.DRYML and point the list-item links to the main-section rather their own pages.  I'm not exactly sure how to do that either.  Any help would be GREATLY appreciated.

Finally, I want to thank you guys for providing a first-rate application builder. If you choose to take the red pill and embrace the vision, you get so much for free.  It's shocking how productive and powerful this tool can be (even in Noobie hands).

Regards,
Paul