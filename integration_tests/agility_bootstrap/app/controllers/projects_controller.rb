class ProjectsController < ApplicationController

  hobo_model_controller

  auto_actions :show, :edit, :update, :destroy, :create

  auto_actions_for :owner, [:new, :create]

  show_action :show2, :show_with_controls, :nested_has_many_test, :dialog_test

  respond_to :html, :xml, :json

  def show
    @project = find_instance
    @stories =
      @project.stories.apply_scopes(:search    => [params[:search], :title],
                                    :status_is => params[:status],
                                    :order_by  => parse_sort_param(:title, :status))
  end

  def show2; show; end

  def show_with_controls; show; end

end
