# Using Lightbox with Hobo

Originally written by Dean on 2010-05-02.

[Lightbox] (http://www.huddletogether.com/projects/lightbox2/) is a simple, unobtrusive script used to overlay images on the current page that is used on many web sites and integrates well with Paperclip.

Using Lightbox with Hobo is very straight forward.

#### Install Lightbox
Download the code from [http://www.huddletogether.com/projects/lightbox2/](http://www.huddletogether.com/projects/lightbox2/)


Copy <i>builder.js, scriptaculous.js, lightbox.js</i> to <i>public/javascripts</i> in your Hobo project.

Copy <i>lightbox.css</i> to <i>public/stylesheets</i> in your Hobo project.

Copy the contents of <i>images</i> to <i>public/images</i> in your Hobo project.

#### Include the Lightbox Javascript and Stylesheet

In application.dryml, extend the page tag to include the Lightbox javascript and stylesheet.

    <extend tag="page">
      <old-page merge>
        <append-scripts:>
          <javascript name="scriptaculous.js?load=effects,builder"/>
          <javascript name="lightbox.js"/>
          <stylesheet name="lightbox.css" media="screen"/>
        </append-scripts:>
      </old-page>
    </extend>

#### Fix a Couple of Issues

In lightbox.js, change the following line:

    LightboxOptions = Object.extend({
        fileLoadingImage:        '/images/loading.gif',
        fileBottomNavCloseImage: '/images/closelabel.gif',

In lightbox.css, change the following line:

    #prevLink, #nextLink{ width: 49%; height: 100%; background-image: url(data:image/gif;base64,AAAA); 
        /* Trick IE into showing hover */ display: block; background-color: transparent; border: 0}
    

#### Modify the Card Tag for Images
In your application.dryml, extend the Card for images:

    <extend tag="card" for="Image" >
      <old-card merge>
        <heading: param>
          <a href="#{this.image.url}" rel="lightbox[#{type_name(:plural => :true,
             :lowercase => :true, :dasherize => :true)}]">
            <img src="#{this.image.url :thumbnail}"/>
          </a>
        </heading:>
      </old-card>
    </extend>


This card will display the thumbnail of images uploaded using Paperclip and display the larger version when the user clicks on it.  When showing a collection of images, clicking on a thumbnail with present a slideshow of the collection that the user can page through.  Images can have a title included by adding a <i>title=</i> attribute to the < a > tag.




