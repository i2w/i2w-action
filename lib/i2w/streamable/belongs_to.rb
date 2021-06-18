# frozen_string_literal: true

module I2w
  class Streamable
    # extension for streamable which sets up a standard belongs to relationship
    module BelongsTo
      def belongs_to(belongs_to_class, foreign_key: nil)
        foreign_key ||= "#{belongs_to_class.model_name.param_key}_id".to_sym

        parent.attribute foreign_key
        parent.define_method(:belongs_to_model) { belongs_to_class.from id: send(foreign_key) }
        parent.define_method(:stream_from) { belongs_to_model }
        parent.define_method(:target) { |prefix = nil| [*prefix, belongs_to_model, model_class] }

        child.define_method(:parent) { Streamable[model_class, foreign_key => model.send(foreign_key)] }
      end
    end
  end
end
