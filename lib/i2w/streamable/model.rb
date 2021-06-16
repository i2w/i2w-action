# frozen_string_literal: true

require 'i2w/data_object'
require_relative 'streamable_methods'

module I2w
  class Streamable
    # Streamable for a model
    class Model < DataObject::Immutable
      include StreamableMethods

      attr_reader :model

      def initialize(model, **attributes)
        @model = model
        super(**attributes)
      end

      def model_class = model.class

      def model_name = model.model_name

      def parent_id(prefix = nil) = parent.target_id(prefix)

      def target(prefix = nil) = [*prefix, model]

      def locals = { model_name.element.to_sym => model, model: model, model_class: model.class, **attributes }

      def partial(prefix = nil) = "#{model_name.collection}/#{prefix}#{prefix ? '_' : ''}#{model_name.element}"

      def parent = Streamable[model_class]
    end
  end
end
