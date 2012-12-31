# Using Highslide with Hobo

Originally written by Dean on 2010-05-18.

[Highslide](http://highslide.com/) is another powerful  image, media and gallery viewer written in JavaScript that is really easy to integrate with Paperclip in Hobo.

Download Highslide from [http://highslide.com/](http://highslide.com/) and unzip the file in the public directory of your application.

In your application.dryml add the following:

    <extend tag="page">
      <old-page merge>
        <append-scripts:>
    
          <javascript name="/highslide/highslide.js"/>
          <stylesheet name="/highslide/highslide.css" media="screen"/>
          <script type="text/javascript">
            // override Highslide settings here
            // instead of editing the highslide.js file
            hs.graphicsDir = '<%=  ActionController::Base.relative_url_root%>/highslide/graphics/';
            hs.showCredits = false;
          </script>
        </append-scripts:>
      </old-page>
    </extend>

    <extend tag="card" for="Image" >
      <old-card merge>
        <header: param>
          <a href="#{this.image.url}" class="highslide"
             onclick="return hs.expand(this)">
            <img src="#{this.image.url :thumbnail}" title="Click to enlarge"/>
          </a>
        </header:>
      </old-card>
    </extend>



