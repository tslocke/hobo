module Hobo

  class CompositeModel

    include ModelSupport

    class << self

      def find(id)
        ids = id.split('_')
        new(*ids.map_with_index{|id, i| @models[i].constantize.find(id)})
      end

      def compose(*models)
        @models = models.map &it.to_s.camelize
        attr_reader *models
        CompositeModel.composites ||= {}
        CompositeModel.composites[@models.sort] = self.name

        Hobo.register_model(self)
      end

      attr_accessor :composites

      attr_reader :models

      def new_for(objects)
        classes = objects.map{|o| o.class.name}.sort
        composite_class = CompositeModel.composites[classes].constantize rescue
          (raise ArgumentError, "No composite model for #{classes.inspect}")
        composite_class.new(*objects)
      end

    end


    def initialize(*objects)
      objects.each do |obj|
        raise ArgumentError, "invalid objects for composition: #{objects.inspect}" unless
          obj.class.name.in? self.class.models
        instance_variable_set("@#{obj.class.name.underscore}", obj)
      end
    end


    def has_hobo_method?(name)
      respond_to?(name)
    end


    def compose_with(object, use=nil)
      self_classes = use ? use.models : self.class.models
      from_self = (self_classes - [object.class.name]).map {|classname| send(classname.underscore)}
      CompositeModel.new_for(from_self + [object])
    end


    def typed_id
      "#{self.class.name.underscore}:#{id}"
    end


    def id
      objects = self.class.models.map {|m| instance_variable_get("@#{m.underscore}")}
      objects.*.id.join("_")
    end

    alias_method :to_param, :id

  end

end

