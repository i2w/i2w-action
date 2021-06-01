require_relative 'streamable_methods'

module I2w
  class Streamable < DataObject::Mutable
    class Parent < DataObject::Mutable
      include StreamableMethods

      attr_reader :model_class

      def initialize(model_class, **attributes)
        super(**attributes)
        @model_class = model_class
      end

      def stream_from = model_class

      def target(prefix = nil) = [*prefix, model_class]

      def locals = { model_class: model_class, **attributes }

      def partial(prefix) = "#{model_class.model_name.collection}/#{prefix}"

      def stream_prefix = [Rails.application.railtie_name]

      def renderer = ActionController::Base
    end
  end
end
