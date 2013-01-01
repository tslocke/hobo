# repeat and collection tags don't seem to work as expected

Originally written by kevinpfromnm on 2010-08-04.

I'm frustrated with DRYML and Rapid.
I can sense the power, but I can't figure out how to get at it.
Literally everything I try to do breaks, and I can't figure out why.

For instance, I have an array of model instances returned by find.
I'd like to try something like this:
<repeat with="&@all">
      <collection/>
</repeat>

where @all=<Model>.find :all, populated in the controller. This seems
like a minimal change from what's in the Agility tutorial, and I can't
tell what's wrong, but I get a method missing exception on empty?.
Eventually I gave up on using <collection> entirely.

I want to modify the edit form so that it shows a textarea instead of
an input type='text' for one field, and there doesn't seem to be any
end to the work.  I create the edit-page, I drop the field from the
field_list, and add the field back in; now it doesn't get put into the
table of label/field combos, and doesn't have a label.
According to the Rapid doc, it seems like I would get a textarea
automagically if I declared the field in my model as note instead of
string, but I shouldn't have to change the data layer to get the
presentation layer that I want.  I feel like there's should be a
simpler way to do this, but for the life of me I can't find it in the
doc. 