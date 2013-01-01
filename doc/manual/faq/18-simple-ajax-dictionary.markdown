# Simple AJAX dictionary

Originally written by qiaozhehui on 2008-10-25.

I have a database with translations of words between two languages and I would like to turn this into a simple AJAX dictionary lookup tool. Basically, there would be a simple search box where the user could enter a search phrase and using AJAX the matching dictionary entries would be found and displayed below the search box (without reloading the page). Additionally, suggested lookup words would appear as the user types in the search box (Live Search style).

It seems that this would be relatively simple to implement with Hobo, but the documentation is still a little sparse and I can't seem to figure out how to do this Hobo-style without falling back to 'regular' rails techniques.