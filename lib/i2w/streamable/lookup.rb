module I2w
  class Streamable < DataObject::Mutable
    module Lookup
      extend self

      def call(*streamable, **opts)
        return streamable[0] if streamable.length == 1 && streamable.is_a?(Streamable)

        prefix, model, model_class = parse_streamable_args(*streamable)

        @streamable_classes = Hash.new { |m, args| m[args] = streamable_class(*args) }
        klass = @streamable_classes[[prefix, model_class]]

        return klass.new(model, **opts) if model

        klass::Parent.new(model_class, **opts)
      end

      private

      def parse_streamable_args(prefix = nil, model_or_model_class)
        unless model_or_model_class.respond_to?(:model_name)
          raise ArgumentError,
                "(prefix or nil, model or model class), got: (#{prefix}, #{model_or_model_class})"
        end

        model = model_or_model_class if model_or_model_class.respond_to?(:to_key)
        model_class = model&.class || model_or_model_class

        [prefix, model, model_class]
      end

      def streamable_class(prefix, model_class)
        namespace = model_class.module_parent
        "#{namespace}::#{prefix&.to_s&.camelize}#{model_class.name.demodulize}Streamable".constantize
      rescue NameError
        begin
          "#{namespace}::ApplicationStreamable".constantize
        rescue NameError
          Streamable
        end
      end
    end
  end
end
