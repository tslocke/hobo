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

(snipped because it was crashing kramdown).   Grab the code from [http://www.dynamicdrive.com/dynamicindex1/dropdowntabfiles/dropdowntabs.js](http://www.dynamicdrive.com/dynamicindex1/dropdowntabfiles/dropdowntabs.js)

4) Insert the following in application.css (again, this should go in its own file, but...

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



