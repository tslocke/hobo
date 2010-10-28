module Generators
  module HoboSupport
    EvalTemplate = classy_module do
      
    private
      def eval_template(template_name)
        source  = File.expand_path(find_in_source_paths(template_name))
        context = instance_eval('binding')
        ERB.new(::File.binread(source), nil, '-').result(context)
      end

    end
  end
end