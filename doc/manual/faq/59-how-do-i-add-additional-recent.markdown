# How do I add additional recent items to an index-page?

Originally written by kevinpfromnm on 2010-08-04.

After going through the tutorials, I decided to re-make the "Recipes" app from the "Four-Tables" tutorial for my own extended family's use, and take it through the whole development, deployment, adjustment cycle.   I got a long way toward making it look the way I wanted, and then struck my personal brick wall with DRYML.  

I decided that the index page for the app should have a little information on it, so I decided to have the three most recently posted recipes appear (just names, and who posted them), along with the three most recent requests (A model I added for people to request recipes from others).   And so I looked at the DRYML I already had, and hit the wall.   I had no idea how to do it.  I had nothing I could even try.   The recipes were too specific to the one-page-one-model (or one-page-one-model-plus-children) views in the tutorials.  And the DRYML guide starts by warning the reader that in fact it won't help in the actual making of Hobo views since the real stuff is in the Rapid Library.  

Ironically, I was able to make it all happen with good old rails, by adding some finds in the controller for the page and some html w/ erb on the view page.   But I'd really like to understand DRYML enough to do it.  Can someone feed me a few lines of the DRYML needed to make this particular thing happen?

If you want to see what I mean, I deployed an unfinished version (for my kids to try and break)  at

http://computer.lsrhs.net/recipes

and you can see what the index page looks like.    I think my next task will be to try and learn DRYML from the bottom up from the manual.  Here goes...

Thanks for all the help past and future,

Mark