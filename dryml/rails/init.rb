# register the path for explicit .dryml files
ActionView::Template.register_template_handler(:dryml, Dryml::TemplateHandler)
# register the path for missing templates
ActionController::Base.view_paths << Dryml::FallbackResolver.new
