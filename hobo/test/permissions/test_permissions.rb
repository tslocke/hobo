# Notes: 
# 
# create/update/delete by guest
# create/update/delete by non-permitted user
# create/update/delete by permitted user
# 
# All of the above for has-many related records
# All of the above for has-many through related records
# All of the above for belongs-to related records
# 
# a permitted user can't create/update/delete any of the obove related records without :accessible


require 'test/unit'

require File.join(File.dirname(__FILE__), "models/models.rb")

require 'shoulda'

Models.init

class PermissionsTest < Test::Unit::TestCase
  
  def assert_create_prevented(*models)
    counts = models.*.count
    assert_raises(Hobo::PermissionDeniedError) { yield }
    assert_equal(counts, models.*.count)
  end
  
  def assert_created(*args)
    expectations = {}
    args.in_groups_of(2) {|model, expected| expectations[model] = [model.count, expected]}
    yield
    expectations.each_pair do |model, nums|
      count = model.count
      delta = model.count - nums.first
      assert_equal(nums.last, delta, "Expected #{nums.last} #{model.name.pluralize} to be created, but #{delta} were")
    end
  end
  
  def assert_change_prevented(record, field)
    was = record.send(field)
    assert_raises(Hobo::PermissionDeniedError) { yield }
    record.reload
    assert_equal was, record.send(field)
  end
  
  def assert_deleted(record)
    assert_raises(ActiveRecord::RecordNotFound) { record.class.find(record.id) }
  end
  
  def assert_destroy_prevented(*records) 
    assert_raises(Hobo::PermissionDeniedError) { yield }
    records.each { |record| assert record.class.find(record.id) }
  end
  
  
  def existing_recipe(user=nil)
    user ||= User.new :name => "existing recipe owner"
    Recipe.create :name => "existing recipe", :user => user
  end
  

  context "The permission system" do
    
    context "with a guest user acting" do
      setup { @guest = Hobo::Guest.new }
      
      should "prevent creation of a recipe" do
        assert_create_prevented(Recipe) { Recipe.user_create! @guest, :name => "test recipe" }
      end
      
      should "prevent update of an exiting recipe" do
        r = existing_recipe
        assert_change_prevented(r, :name) { r.user_update_attributes!(@guest, :name => "pwned!") }
      end
      
      should "prevent deletion of an existing recipe" do
        r = existing_recipe
        assert_destroy_prevented(r) { r.user_destroy(@guest) }
      end
      
    end
    
    context "with a regular user acting" do
      
      setup { @user = User.create! :name => "regular" } 
      
      
      # --- Permitted basic actions --- #
      
      should "allow creation of a recipe" do
        assert_created Recipe, 1 do
           @recipe = Recipe.user_create! @user, :name => "test recipe"
        end
        assert_equal(@user, @recipe.user)
      end

      should "allow update of a recipe (owned by the acting user)" do
        r = existing_recipe(@user)
        r.user_update_attributes!(@user, :name => "new name")
        r.reload
        assert_equal("new name", r.name)
      end
      
      should "allow deletion of a recipe (owned by the acting user)" do
        r = existing_recipe(@user)
        r.user_destroy(@user)
        assert_deleted r
      end


      # ---- Prevented basic actions --- #

      should "prevent creation of a recipe owned by another user" do
        assert_create_prevented(Recipe) { Recipe.user_create! @user, :name => "test recipe", :user => User.new }
      end
      
      context "on a recipe owned by another user" do
        setup { @r = existing_recipe(User.create!(:name => "a n other")) }
    
        should "prevent update" do
          assert_change_prevented(@r, :name) { @r.user_update_attributes!(@user, :name => "pwned!") }
        end
      
        should "prevent deletion" do
          assert_destroy_prevented(@r) { @r.user_destroy(@user) }
        end
        
      end
      
      
      # --- Prevented actions on has_many related records --- #
    
      # (sanity check)
      should "prevent creation of images without a recipe" do
        assert_create_prevented(Image) { Image.user_create! @user, :name => "test image" }
      end
    
      should "prevent creation of images along with a recipe" do # Only paid up users can
        assert_create_prevented(Recipe, Image) do
          Recipe.user_create! @user, :name => "test recipe",
                                     :images => { '0' => { :name => "image 1" },
                                                  '1' => { :name => "image 2" } }
        end
      end
      
      context "on an another's recipe with images" do
        setup do
          user = User.create :name => "a n other"
          @r = Recipe.create! :name => "test recipe", :user => user
          @i1 = @r.images.create(:name => "image 1")
          @i2 = @r.images.create(:name => "image 2")
        end
          
        should "prevent update of those images" do
          assert_change_prevented(@i1, :name) do
            @r.user_update_attributes!(@user, :images => { '0' => { :id => @i1.id, :name => "pwned!" } })
          end
        end
      
        should "prevent deletion of those images" do
          assert_destroy_prevented(@i1, @i2) { @r.user_update_attributes!(@user, :images => { }) }
        end
      end
      
      # Note: permitted actions on has-many associated records are in the paid-up user section
      # Tis the tyranny of the dominant hiearchy : )
      

      # --- Permitted actions on has_many :through relationships --- #
      
      context "" do
        setup do
          @c1 = User.create :name => "Collaborator 1"
          @c2 = User.create :name => "Collaborator 2"
        end
      
        should "allow adding collaborators when creating a recipe" do
          @r = Recipe.user_create! @user, :name => "my recipe", 
                                          :collaborators => { '0' => "@#{@c1.id}", '1' => "@#{@c2.id}" }
          assert_equal(@r.collaborators, [@c1, @c2])
        end
      
        should "allow adding collaborators to a recipe" do
          @r = existing_recipe(@user)
        
          @r.user_update_attributes! @user, :collaborators => { '0' => "@#{@c1.id}", '1' => "@#{@c2.id}" }
          assert_equal(@r.collaborators, [@c1, @c2])
        end
      
        should "allow removing collaborators from a recipe" do
          @r = existing_recipe(@user)
          @r.collaborators << @c1
          @r.collaborators << @c2          
          join1, join2 = @r.collaboratorships
          
          # sanity check
          @r.reload
          assert_equal(@r.collaborators.length, 2)

          @r.user_update_attributes! @user, :collaborators => {}
          assert_equal(@r.collaborators.length, 0)
          
          assert_deleted(join1)
          assert_deleted(join2)
        end
      
      
        # --- Prevented actions on has_many :through relationships --- #
      
        context "on another's recipe" do
          setup do
            other_user = User.create :name => "a n other"
            @r = existing_recipe(other_user)
          end
      
          should "prevent adding collaborators" do
            assert_create_prevented(Collaboratorship) do 
              @r.user_update_attributes! @user, :collaborators => { '0' => "@#{@c1.id}", '1' => "@#{@c2.id}" }
            end
          end

          should "prevent removing collaborators" do
            c1 = User.create :name => "Collaborator 1"
            c2 = User.create :name => "Collaborator 2"
            @r.collaborators << c1
            @r.collaborators << c2
            join1, join2 = @r.collaboratorships

            assert_destroy_prevented(join1, join2) do
              @r.user_update_attributes! @user, :collaborators => {}
            end
          end
        end
      
      end
      
      # --- Permitted actions on a belongs_to related record --- #
      
      should "allow creation of a code-example along with a recipe" do
        assert_created(Recipe, 1, CodeExample, 1) do
          @r = Recipe.user_create! @user, :name => "recipe with code example", 
                                         :code_example => { :filename => "code.zip" }
        end
        assert_equal("code.zip", @r.code_example.filename)
      end
      
      should "allow creation of a code-example for an existing recipe" do
        @r = existing_recipe(@user)
        assert_created(CodeExample, 1) do
          @r.user_update_attributes! @user, :code_example => { :filename => "code.zip" }
        end
        assert_equal("code.zip", @r.code_example.filename)        
      end
      
      context "on an existing recipe with a code example" do 
        setup do
          @ce = CodeExample.create! :filename => "exmaple.zip"
          @r = Recipe.create :name => "existing recipe", :user => @user, :code_example => @ce
        end
      
        should "allow update of the code-example" do
          @r.user_update_attributes! @user, :code_example => { :filename => "changed.zip" }
          assert_equal("changed.zip", @r.code_example.filename)
        end

        should "allow removal of the code-example" do
          @r.user_update_attributes! @user, :code_example => { }
          @r.reload
          assert_nil @r.code_example
          # Note - the code-example is not deleted from the database
        end
        
      end
      
      
      # --- Prevented actions on a belongs_to related record --- #
      
      context "on another's recipe" do
        setup { @r = existing_recipe }

        should "prevent creation of a code-example" do
          assert_create_prevented(CodeExample) do
            @r.user_update_attributes! @user, :code_example => { :filename => "code.zip" }
          end
        end
        
        context "with a code example" do
          setup do
            @ce = @r.code_example = CodeExample.create!(:filename => "exmaple.zip")
            @r.save
          end
      
          should "prevent update of the code-example" do
            assert_change_prevented(@ce, :filename) do
              @r.user_update_attributes! @user, :code_example => { :filename => "changed.zip" }
            end
          end

          should "prevent removal of the code-example" do
            assert_change_prevented(@r, :code_example_id) do
              @r.user_update_attributes! @user, :code_example => {}
            end
            
          end
        end
      end      
      
      # --- Actions on non-accesible has_many associations --- #
      
      should_eventually "prevent creation of comments via a recip" do
        
      end
      
      should_eventually "precent update of comments via their recipe" do
        
      end
      
      should_eventually "prevent deletion of comments via their recipe" do
        
      end
      
      
      # --- Actions on non-accessible belongs_to associations --- #
      
      should_eventually "prevent creation of a recipe when creating a comment" do
        
      end
      
      should_eventually "prevent update of a recipe via one of its comments" do
        
      end
      
      should_eventually "prevent deletion of a recipe via one of its comments" do
        
      end
      
    end
        
    context "with a paid up user acting" do
      setup { @user = User.create! :name => "paid up user", :paid_up => true }
    
      should "prevent direct creation of images" do # images must belong to a recipe
        assert_create_prevented(Image) { Image.user_create! @user, :name => "test image" }
      end
      
      # --- Permitted actions on has_many related records --- #
    
      should "allow creation of images along with a recipe" do
        
        assert_created Recipe, 1, Image, 2 do
          @recipe = Recipe.user_create! @user, :images => { '0' => { :name => "image 1" },
                                                            '1' => { :name => "image 2" } }

          assert_equal(2, @recipe.images.length)
          i1, i2 = @recipe.images
          assert_equal("image 1", i1.name)
          assert_equal("image 2", i2.name)

          assert_equal(@recipe, i1.recipe)
          assert_equal(@recipe, i2.recipe)
        end

      end
      
      context "on an existing recipe with images" do
        setup do
          @recipe = Recipe.create! :name => "recipe with images", :user => @user
          @i1 = @recipe.images.create! :name => "image 1"
          @i2 = @recipe.images.create! :name => "image 2"
        end      
      
        should "allow creation of images when updating a recipe" do
          @recipe.user_update_attributes! @user, :images => { '0' => { :id => @i1.id },
                                                              '1' => { :id => @i2.id },
                                                              '2' => { :name => "new image" } }
          @recipe.reload
          assert_equal(3, @recipe.images.length)
          assert_equal("image 1", Image.find(@i1.id).name)
          assert_equal("image 2", Image.find(@i2.id).name)
          assert_equal("new image", @recipe.images[2].name)
        end
      
        should "allow updates to images when updating a recipe" do
          @recipe.user_update_attributes! @user, :images => { '0' => { :id => @i1.id, :name => "new name" },
                                                              '1' => { :id => @i2.id } }
          @recipe.reload
          assert_equal(2, @recipe.images.length)
          assert_equal("new name", Image.find(@i1.id).name)
          assert_equal("new name", @recipe.images[0].name)
        end
      
        should "allow deletion of images when updating a recipe" do
          @recipe.user_update_attributes! @user, :images => { '0' => { :id => @i1.id } }
          @recipe.reload
          assert_equal(1, @recipe.images.length)
          assert_deleted(@i2)
        end
      
      end
        
    
    end
    
  end  
  
end  
