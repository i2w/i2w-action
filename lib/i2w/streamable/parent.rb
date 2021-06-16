require_relative 'streamable_methods'

module I2w
  class Streamable
    class Parent < DataObject::Mutable
      include StreamableMethods

      attr_reader :model_class

      def initialize(model_class, **attributes)
        super(**attributes)
        @model_class = model_class
      end

      def target(prefix = nil) = [*prefix, model_class]

      def locals = { model_class: model_class, **attributes }

      def partial(prefix) = "#{model_class.model_name.collection}/#{prefix}"
    end
  end
end
