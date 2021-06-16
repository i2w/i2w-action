require_relative 'streamable_methods'

module I2w
  class Streamable
    class Parent < DataObject::Immutable
      include StreamableMethods

      attr_reader :model_class

      def initialize(model_class, **attributes)
        @model_class = model_class
        super(**attributes)
      end

      def stream_from = model_class

      def target(prefix = nil) = [*prefix, model_class]

      def locals = { model_class: model_class, **attributes }

      def partial(prefix) = "#{model_class.model_name.collection}/#{prefix}"
    end
  end
end
