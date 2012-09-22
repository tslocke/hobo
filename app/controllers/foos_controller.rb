class FoosController < ApplicationController

  hobo_model_controller

  auto_actions :all

  show_action :show_editors
  show_action :refresh_bug305part

  index_action :bug_414_test do
    @my_table = [ { "left" => "unlucky", "right" => 13 },
                  { "left" => "the answer", "right" => 42} ]
  end
end
