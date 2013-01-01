# Toggle with images

Originally written by robi on 2008-10-30.

Im struggling to workout how to add (expand and collapse) images to this toggle code.  Can anyone help please.  I presume you insert one image for the first click, and a second one for the next click - but cant work out where to insert the link:

<def tag="toggle"> 
  <div> 
    <a href="#" onclick="$(this).next().toggle(); return false;" param="title"><%= this_field._?.titleize %></a> 
    <div style="display:none;" param="body"><view/></div> 
  </div> 
</def>

<toggle> 
	    <title:><h2>  </h2></title:> 
	 <body:>
	</body:> 
</toggle>