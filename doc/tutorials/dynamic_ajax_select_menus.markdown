# Dynamic Ajax select menus

This is an updated version for Hobo 2.0 of two older recipes
* [Ajax filtering on a partially completed form](http://cookbook.hobocentral.net/tutorials/33-ajax-filtering-on-a-partially-completed)
* [Dynamically populated select menus](http://cookbook.hobocentral.net/tutorials/15-dynamically-populated-select-menus)

# Get the code

[The code for this recipe is available on github](https://github.com/iox/hobo_recipe_dynamic_menus)

# Introduction

A common requirement in user-interfaces is to have the options available in one menu depend on the selection in another menu. For example, before you can select a city you have to select a country; on selecting the country the city menu is populated with cities from that country. This recipe shows how to accomplish exatly that using Hobo's ajax mechanism and a little custom JavaScript.

This is a "from scratch" recipe - we build an app from scratch that has this feature.

# Create the app

Get started as normal:

    $ hobo new dynamic_menus
    
Then add some models. We'll have a project that belongs to both a city and a country:

    $ hobo g resource project name:string
    $ hobo g model country name:string
    $ hobo g model city name:string
    
Now define the relationships as follows:
    
    class Project
      belongs_to :country
      belongs_to :city
    end
    
    class City
      belongs_to :country
      has_many :projects
    end
    
    class Country 
      has_many :cities
      has_many :projects
    end
{: .ruby}
    
Create the initial database    
    
    hobo g migration
    
# Add some data

Let's use a migration to add some cities and contries
    
    rails g migration populate_countries_and_cities
    
Here's the up migration (there's no need for a down in this case, since the schema doesn't change)
    
    def up
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
{.dryml}

Try adding that to front_site.dryml and then create a project. The new project wont have a country, so the city menu will be disabled. But if you chose a country, create the project and then go to edit it, you should see the cities from that country in the city menu. We're making progress.

# Add the ajax magic

We now need to do three things to add the ajax behaviour and tie it all together:

 - Put the city menu in an ajax 'part' so that it can be updated dynamically (`<do>` is just a do nothing tag that can be used to add parts or params without changing the markup)

 - Add a formlet capable of updating the 'part'

 - Add some JavaScript to the country select onchange event to trigger the formlet


The updated code:

    <extend tag="form" for="Project">
      <old-form merge>
        <field-list: fields="name, country, city">
          <country-view:>
            <select-one onchange="
              $('#city-menu-form #country-field').val(this.value);
              $('#city-menu-form').hjq_formlet('submit')" />
          </country-view:>
          
          <city-view:>
            <do part="city-menu">
              <if test="&@project.country">
                <select-one options="&@project.country.cities"/>
              </if>
              <else>
                <select disabled><option>First choose a country</option></select>
              </else>
            </do>
            
            <formlet action="/projects/new" method="get" id="city-menu-form" updates="#city-menu">
              <input id="country-field" name="project[country_id]" value="" type="hidden"/>
            </formlet>
          </city-view:>
        </field-list:>
      </old-form>
    </extend> 
{.dryml}

It should now all be working :o)


# Update: Refactoring the code with hot-input

A month after writing this recipe I came across `hot-input`, a new tag that allows us to refactor this code in a very nice way. This is the same form with hot-input:

        <extend tag="form" for="Project">
          <old-form merge>
            <field-list: replace>
              <do part="shipping">
                <field-list fields="name, country, city">
                  <country-view:><hot-input ajax /></country-view:>
                  <city-view:>
                    <if test="&this_parent.country">
                      <select-one options="&this_parent.country.cities"/>
                    </if>
                    <else>
                      <select disabled><option>First choose a country</option></select>
                    </else>
                  </city-view:>
                </field-list>
              </do>
            </field-list:>
          </old-form>
        </extend>
{.dryml}

This is much shorter and works exactly the same :).

[More info about hot-input](http://cookbook.hobocentral.net/tagdef/hobo_rapid/inputs/hot-input)
