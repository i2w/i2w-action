module I2w
  class Streamable < DataObject::Mutable
    module DomId
      extend self

      def call(*parts)
        result = parts.map { id_for_part(_1) }.flatten.join('_')
        result = result.singularize if parts.first.is_a?(Symbol) && parts.last.is_a?(Class)
        result
      end

      private

      def id_for_part(part)
        return part.to_s unless part.respond_to?(:model_name)
        return part.model_name.plural unless part.respond_to?(:to_key)

        [part.model_name.singular, *part.to_key].map(&:to_s)
      end
    end
  end
end
