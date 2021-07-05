module I2w
  class Streamable
    # responsible for looking up streamables given objects
    module Lookup
      extend self

      def call(*streamable, **opts)
        return streamable[0] if streamable.length == 1 && streamable.is_a?(Streamable)

        namespace = streamable.shift if streamable[0].is_a?(Module) && !streamable[0].is_a?(Class)
        
        prefix, model, model_class = parse_streamable_args(*streamable)

        @streamable_classes = Hash.new { |m, args| m[args] = streamable_class(*args, namespace: namespace) }
        streamable_class = @streamable_classes[[prefix, model_class]]

        return streamable_class::Model.new(model, **opts) if model

        streamable_class::ModelClass.new(model_class, **opts)
      end

      private

      def parse_streamable_args(prefix = nil, model_or_model_class)
        unless model_or_model_class.respond_to?(:model_name)
          raise ArgumentError, "(prefix or nil, model or model class), got: (#{prefix}, #{model_or_model_class})"
        end

        model = model_or_model_class if model_or_model_class.respond_to?(:to_key)
        model_class = model&.class || model_or_model_class

        [prefix, model, model_class]
      end

      def streamable_class(prefix, model_class, namespace: nil)
        klass = streamable_class_in_namespace(prefix, model_class, namespace) if namespace
        klass ||= streamable_class_in_namespace(prefix, model_class, model_class.module_parent)

        klass || Streamable
      end

      def streamable_class_in_namespace(prefix, model_class, namespace)
        "#{namespace}::#{prefix&.to_s&.camelize}#{model_class.name.demodulize}Streamable".constantize
      rescue NameError
        application_streamable_in_namespace(namespace)
      end

      def application_streamable_in_namespace(namespace)
        "#{namespace}::ApplicationStreamable".constantize
      rescue NameError
        nil
      end
    end
  end
end
