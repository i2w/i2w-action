# frozen_string_literal: true

module I2w
  class Streamable
    # extension for streamable which sets up a standard belongs to relationship
    module BelongsTo
      def belongs_to(belongs_to_class, foreign_key: nil)
        foreign_key ||= "#{belongs_to_class.model_name.param_key}_id".to_sym

        define_method(:belongs_to_class) { belongs_to_class }

        model_class do
          attribute foreign_key
          define_method(:belongs_to_model) { belongs_to_class.from id: send(foreign_key) }
          define_method(:target) { |prefix = nil| [*prefix, belongs_to_model, model_class] }
        end

        model do
          define_method(:belongs_to_model) { belongs_to_class.from id: model.send(foreign_key) }
          define_method(:parent) { streamable(model_class, foreign_key => belongs_to_model.id) }
        end
      end
    end
  end
end
