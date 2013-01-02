# Dynamically populated `<select>` menus

Originally written by Tom on 2008-10-29.

(Note: this recipe requires Edge Hobo as of 29 Oct '08)

# Get the code

[The code for this recipe is available on github](http://github.com/tablatom/hoborecipes/tree/master/dynamic_menus)

(don't forget to `git submodule update` to get Hobo)

# Introduction

A common requirement in user-interfaces is to have the options available in one menu depend on the selection in another menu. For example, before you can select a city you have to select a country; on selecting the country the city menu is populated with cities from that country. This recipe shows how to accomplish exatly that using Hobo's ajax mechanism and a little custom JavaScript.

This is a "from scratch" recipe - we build an app from scratch that has this feature.

# Create the app

Get started as normal:

    $ hobo dynamic_menus
    
Then add some models. We'll have a project that belongs to both a city and a country:

    $ ./script/generate hobo_model_controller project name:string
    $ ./script/generate hobo_model country name:string
    $ ./script/generate hobo_model city name:string
    
Now define the relationships as follows:
    
    class Project
      belongs_to :country
      belongs_to :city
    end
    
    class City
      belongs_to :country
    end
    
    class Country 
      has_many :cities
    end
{: .ruby}
    
Create the initial database    
    
    ./script/generate hobo_migration
    
# Add some data

Let's use a migration to add some cities and contries
    
    ./script/generate migration populate_countries_and_cities
    
Here's the up migration (there's no need for a down in this case, since the schema doesn't change)
    
    def self.up
      countries = { "UK"     => %w(London Birmingham Manchester Sheffield Bristol), 
                    "USA"    => ['Washington D.C.', 'New York', 'Los Angeles', 'San Fransisco'],
                    "France" => %w(Paris Nice Marseille Lyon Toulouse)
                  }

      countries.each_pair do |country, cities|
        c = Country.create :name => country
        cities.each { |city| c.cities.create :name => city  }
      end
    end
{: .ruby}

Don't forget to

    $ rake db:migrate
    
OK - fire her up. Once you've signed up you'll see you have a regular "New Project" page, but *all* of the cities are in the cities menu. Not what we want.

# Customise the Project form

Here's a custom version of the project form that populates the city menu according to the projects country:

    <extend tag="form" for="Project">
      <old-form merge>
        <field-list: fields="name, country, city">
          <city-view:>
            <if test="&@project.country">
              <select-one options="&@project.country.cities"/>
            </if>
            <else>
              <select disabled><option>First choose a country</option></select>
            </else>
          </city-view:>
        </field-list:>
      </old-form>
    </extend>
{: .dryml}
    
Try adding that to application.dryml and then create a project. The new project wont have a country, so the city menu will be disabled. But if you chose a country, create the project and then go to edit it, you should see the cities from that country in the city menu. We're making progress.

# Add the ajax magic

We now need to do three things to add the ajax behaviour and tie it all together:

 - Put the city menu in an ajax 'part' so that it can be updated dynamically

 - Add some JavaScript to application.js to send to the server (via an ajax call) a change to the country whenever the menu changes

 - Customize the `new` and `edit` actions in `ProjectsController` so that they can update the project from parameters (i.e. the parameters sent by the ajax call)
 

## Put the city menu in a part

Add a `<do part="city-menu">` to the cusomtised form (`<do>` is just a do nothin tag that can be used to add parts or params without changing the markup)
 
    <extend tag="form" for="Project">
      <old-form merge>
        <field-list: fields="name, country, city">
          <city-view:>
            <do part="city-menu">
              <if test="&@project.country">
                <select-one options="&@project.country.cities" disabled/>
              </if>
              <else>
                <select disabled><option>First choose a country</option></select>
              </else>
            </do>
          </city-view:>
        </field-list:>
      </old-form>
    </extend>    
{: .dryml}

## Add the JavaScript

We'll use JavaScript to notify the server when the country is changed. Rather than clutter up the page we'll do this 'unobtrusively' by adding a call to `Event.addBehavior` to our application.js:

    Event.addBehavior({

        "form.project select.project-country:change": function(ev) {
            Hobo.ajaxRequest(window.location.href, ['city-menu'], 
                             { params: Form.serializeElements([this]), method: 'get',
                               spinnerNextTo: this, message: ""} )
        }

    })
    
Let's go through we did there:

  - Added an `onchange` handler to our select. We used Hobo's default CSS class names to target the right `<select>`
    
  - Used `Hobo.ajaxRequest` to send a request to the server along with the necessary parameters to trigger the part update:
      - We used `window.location.href` to send the request to the same URL where the form lives
      - The second parameter is an array of part-names that we want updated
      - We used `Form.serializeElements([this])` (from Prototype) to get the required parameter to update the model's country (in an addBehavior callback, `this` is the element that generated the event)
      
And finally:

## Customise the controller

The `new` and `edit` actions in `ProjectsController` need to update the project with the change (if present) that the ajax call sent up. We also need to tell them to perform an ajax part update if the request is from javascript (`request.xhr?`).

Add these methods to `ProjectsConrtoller`:

    def new
      hobo_new do
        this.attributes = params[:project] || {}
        hobo_ajax_response if request.xhr?
      end
    end

    def edit
      hobo_show do
        this.attributes = params[:project] || {}
        hobo_ajax_response if request.xhr?
      end
    end
    
It should now all be working :o)




