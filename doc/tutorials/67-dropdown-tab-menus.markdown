# Dropdown tab menus

Originally written by dziesig on 2011-02-22.

One of my clients insisted on having drop-down menus on her website.  Since "The Client is Always Right" (tm), I had to find a quick way of doing this.

1) put main-nav in its own file. I used app/views/taglibs/main-nav.dryml. Once you do this, the automatic updating of menus stops, any future changes to the displayed menu must be done manually to this file.

2) add the following code to main-nav.dryml

    <!-- ====== Main Navigation ====== -->

    <def tag="main-nav">
      <div id="my_menu_id"  class="navigation main-nav"> <!-- NEW -->
        <navigation  class="main-nav" merge-attrs param="default">

    *
    *
    *
          <!-- note the '#' is used to dis-allow clicking on the root menu item -->
          <!-- It is perfectly allowable to insert a link at this point, too    -->
          <li class="">
	    <a href='#' rel="my_dropdown_1"><t key="my_dropdown_1.nav_item"/></a>
	  </li>
    *
    *
    *

          <li class="">
	    <a href='#' rel="my_dropdown_2"><t key="my_dropdown_2.nav_item"/></a>
	  </li>

    *
    *
    *
        <!--/navigation> <!-- original closing tag -->
      </div> <!-- NEW -->

      <!-- Add your dropdown menus as needed -->
      <div id="my_dropdown_1" class="my_drop_down_div">		
        <a href = "#{base_url}/dropdown_1_1"><t key="dropdown_1_1.nav_item"/></a>
	<a href = "#{base_url}/dropdown_1_2"><t key="dropdown_1_2.nav_item"/></a>
	<a href = "#{base_url}/dropdown_1_3"><t key="dropdown_1_3.nav_item"/></a>
	<a href = "#{base_url}/dropdown_1_4"><t key="dropdown_1_4.nav_item"/></a>
      </div>

      <div id="my_dropdown_2" class="my_drop_down_div">		
        <a href = "#{base_url}/dropdown_2_1"><t key="dropdown_2_1.nav_item"/></a>
	<a href = "#{base_url}/dropdown_2_2"><t key="dropdown_2_2.nav_item"/></a>
	<a href = "#{base_url}/dropdown_2_3"><t key="dropdown_2_3.nav_item"/></a>
	<a href = "#{base_url}/dropdown_2_4"><t key="dropdown_2_4.nav_item"/></a>
      </div>

    /***********************************************

    * Drop Down Tabs Menu- (c) Dynamic Drive DHTML code library (www.dynamicdrive.com)

    * This notice MUST stay intact for legal use

    * Visit Dynamic Drive at http://www.dynamicdrive.com/ for full source code

    ***********************************************/



      <!-- initialize the supporting js -->

      <script type="text/javascript">
        //SYNTAX: tabdropdown.init("menu_id", [integer OR "auto"])
        tabdropdown.init("my_menu_id", "auto")
      </script>

    </def> <!-- The original end tag -->

3) Insert the following code in application.js (This should go in its own file, but I couldn't get it to work that way, at least in any reasonable time).

    //Drop Down Tabs Menu- Author: Dynamic Drive (http://www.dynamicdrive.com)
    //Created: May 16th, 07'
    /***********************************************

    * Drop Down Tabs Menu- (c) Dynamic Drive DHTML code library (www.dynamicdrive.com)

    * This notice MUST stay intact for legal use

    * Visit Dynamic Drive at http://www.dynamicdrive.com/ for full source code

    ***********************************************/
    
    var tabdropdown={
    	disappeardelay: 200, //set delay in miliseconds before menu disappears onmouseout
    	disablemenuclick: false, //when user clicks on a menu item with a drop down menu, disable menu item's link?
    	enableiframeshim: 1, //1 or 0, for true or false

    	//No need to edit beyond here////////////////////////
    	dropmenuobj: null, ie: document.all, firefox: document.getElementById&&!document.all, previousmenuitem:null,
    	currentpageurl: window.location.href.replace("http://"+window.location.hostname, "").replace(/^\//, ""), //get current page url (minus hostname, ie: http://www.dynamicdrive.com/)

    	getposOffset:function(what, offsettype){
    		var totaloffset=(offsettype=="left")? what.offsetLeft : what.offsetTop;
    		var parentEl=what.offsetParent;
    			while (parentEl!=null){
    				totaloffset=(offsettype=="left")? totaloffset+parentEl.offsetLeft : totaloffset+parentEl.offsetTop;
				parentEl=parentEl.offsetParent;
    			}
    		return totaloffset;
    	},

    	showhide:function(obj, e, obj2){ //obj refers to drop down menu, obj2 refers to tab menu item mouse is currently over
    		if (this.ie || this.firefox)
    			this.dropmenuobj.style.left=this.dropmenuobj.style.top="-500px"
    		if (e.type=="click" && obj.visibility==hidden || e.type=="mouseover"){
    			if (obj2.parentNode.className.indexOf("default")==-1) //if tab isn't a default selected one
    				obj2.parentNode.className="selected"
    			obj.visibility="visible"
    			}
    		else if (e.type=="click")
    			obj.visibility="hidden"
    	},

    	iecompattest:function(){
    		return (document.compatMode && document.compatMode!="BackCompat")? document.documentElement : document.body
    	},

    	clearbrowseredge:function(obj, whichedge){
    		var edgeoffset=0
    		if (whichedge=="rightedge"){
    			var windowedge=this.ie && !window.opera? this.standardbody.scrollLeft+this.standardbody.clientWidth-15 : window.pageXOffset+window.innerWidth-15
    			this.dropmenuobj.contentmeasure=this.dropmenuobj.offsetWidth
    		if (windowedge-this.dropmenuobj.x < this.dropmenuobj.contentmeasure)  //move menu to the left?
    			edgeoffset=this.dropmenuobj.contentmeasure-obj.offsetWidth
    		}
    		else{
    			var topedge=this.ie && !window.opera? this.standardbody.scrollTop : window.pageYOffset
    			var windowedge=this.ie && !window.opera? this.standardbody.scrollTop+this.standardbody.clientHeight-15 : window.pageYOffset+window.innerHeight-18
    			this.dropmenuobj.contentmeasure=this.dropmenuobj.offsetHeight
    			if (windowedge-this.dropmenuobj.y < this.dropmenuobj.contentmeasure){ //move up?
				   edgeoffset=this.dropmenuobj.contentmeasure+obj.offsetHeight
    				if ((this.dropmenuobj.y-topedge)<this.dropmenuobj.contentmeasure) //up no good either?
    					edgeoffset=this.dropmenuobj.y+obj.offsetHeight-topedge
    			}
    			this.dropmenuobj.firstlink.style.borderTopWidth=(edgeoffset==0)? 0 : "1px" //Add 1px top border to menu if dropping up
    		}
    		return edgeoffset
    	},

    	dropit:function(obj, e, dropmenuID){
    		if (this.dropmenuobj!=null){ //hide previous menu
			this.dropmenuobj.style.visibility="hidden" //hide menu
    			if (this.previousmenuitem!=null && this.previousmenuitem!=obj){
    				if (this.previousmenuitem.parentNode.className.indexOf("default")==-1) //If the tab isn't a default selected one
    					this.previousmenuitem.parentNode.className=""
    			}
    		}
    		this.clearhidemenu()
    		if (this.ie||this.firefox){
    			obj.onmouseout=function(){tabdropdown.delayhidemenu(obj)}
    			obj.onclick=function(){return !tabdropdown.disablemenuclick} //disable main menu item link onclick?
    			this.dropmenuobj=document.getElementById(dropmenuID)
    			this.dropmenuobj.onmouseover=function(){tabdropdown.clearhidemenu()}
    			this.dropmenuobj.onmouseout=function(e){tabdropdown.dynamichide(e, obj)}
    			this.dropmenuobj.onclick=function(){tabdropdown.delayhidemenu(obj)}
    			this.showhide(this.dropmenuobj.style, e, obj)
    			this.dropmenuobj.x=this.getposOffset(obj, "left")
    			this.dropmenuobj.y=this.getposOffset(obj, "top")
    			this.dropmenuobj.style.left=this.dropmenuobj.x-this.clearbrowseredge(obj, "rightedge")+"px"
    			this.dropmenuobj.style.top=this.dropmenuobj.y-this.clearbrowseredge(obj, "bottomedge")+obj.offsetHeight+1+"px"
    			this.previousmenuitem=obj //remember main menu item mouse moved out from (and into current menu item)
    			this.positionshim() //call iframe shim function
    		}
    	},

    	contains_firefox:function(a, b) {
    		while (b.parentNode)
    		if ((b = b.parentNode) == a)
    			return true;
    		return false;
    	},

    	dynamichide:function(e, obj2){ //obj2 refers to tab menu item mouse is currently over
    		var evtobj=window.event? window.event : e
    		if (this.ie&&!this.dropmenuobj.contains(evtobj.toElement))
    			this.delayhidemenu(obj2)
    		else if (this.firefox&&e.currentTarget!= evtobj.relatedTarget&& !this.contains_firefox(evtobj.currentTarget, evtobj.relatedTarget))
    			this.delayhidemenu(obj2)
    	},

    	delayhidemenu:function(obj2){
    		this.delayhide=setTimeout(function(){tabdropdown.dropmenuobj.style.visibility='hidden'; if (obj2.parentNode.className.indexOf('default')==-1) obj2.parentNode.className=''},this.disappeardelay) //hide menu
    	},

    	clearhidemenu:function(){
    		if (this.delayhide!="undefined")
    			clearTimeout(this.delayhide)
    	},

    	positionshim:function(){ //display iframe shim function
    		if (this.enableiframeshim && typeof this.shimobject!="undefined"){
    			if (this.dropmenuobj.style.visibility=="visible"){
				this.shimobject.style.width=this.dropmenuobj.offsetWidth+"px"
				this.shimobject.style.height=this.dropmenuobj.offsetHeight+"px"
    				this.shimobject.style.left=this.dropmenuobj.style.left
    				this.shimobject.style.top=this.dropmenuobj.style.top
    			}
    		this.shimobject.style.display=(this.dropmenuobj.style.visibility=="visible")? "block" : "none"
    		}
    	},

    	hideshim:function(){
    		if (this.enableiframeshim && typeof this.shimobject!="undefined")
    			this.shimobject.style.display='none'
    	},

    isSelected:function(menuurl){
    	var menuurl=menuurl.replace("http://"+menuurl.hostname, "").replace(/^\//, "")
    	return (tabdropdown.currentpageurl==menuurl)
    },

    	init:function(menuid, dselected){
    		this.standardbody=(document.compatMode=="CSS1Compat")? document.documentElement : document.body //create reference to common "body" across doctypes
    		var menuitems=document.getElementById(menuid).getElementsByTagName("a")
    		for (var i=0; i<menuitems.length; i++){
    			if (menuitems[i].getAttribute("rel")){
    				var relvalue=menuitems[i].getAttribute("rel")
				document.getElementById(relvalue).firstlink=document.getElementById(relvalue).getElementsByTagName("a")[0]
    				menuitems[i].onmouseover=function(e){
    					var event=typeof e!="undefined"? e : window.event
    					tabdropdown.dropit(this, event,    this.getAttribute("rel"))
    				}
    			}
    			if (dselected=="auto" && typeof setalready=="undefined" && this.isSelected(menuitems[i].href)){
    				menuitems[i].parentNode.className+=" selected default"
    				var setalready=true
    			}
    			else if (parseInt(dselected)==i)
    				menuitems[i].parentNode.className+=" selected default"
    		}
    	}

    }

    /* End of Dropdown menu code */

4) Insert the following in application.css (again, this should go in its own file, but..._

/* ######### Style for Drop Down Menu ######### */

.my_drop_down_div
{
  position:absolute;
  top: 0;
  border : none;
  line-height:18px;
  z-index:100;
  background-color: #ff0000; 
  width: 110px;
  visibility: hidden;
  font:10px/18px "Lucida Grande","Trebuchet MS",Arial,sans-serif;
}


.my_drop_down_div a
{
	width: auto;
	display: block;
	text-indent: 5px;
	padding: 2px 0;
	text-decoration: none;
	color: white;
	background:  #242E42;
}

* html .my_drop_down_div a /*IE only hack*/
{
  width: 100%;
}

.my_drop_down_div a:hover /*THEME CHANGE HERE*/
{
  color: #242E42;
  background-color: #ffffff; 
}


I fiddled with the css until the drop down looked like the main tabs.  You will probably want to adjust the width to suit your drop down menu width, but it seems to adjust itself appropriately for most cases.



