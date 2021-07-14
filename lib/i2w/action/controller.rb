# frozen_string_literal: true

require 'i2w/repo/base'
require_relative 'controller/crud_actions'

module I2w
  class Action
    # mixin for ActionController::Base
    module Controller
      extend ActiveSupport::Concern

      included do
        extend Repo::Base.extension :controller,
                                    accessors: %i[repository input model action],
                                    to_base: proc { _1.sub(/Controller\z/, '').singularize },
                                    from_base: proc { raise "Can't lookup :controller from #{_1}" }
      end

      private

      delegate :repository_class, :input_class, :model_class, :action_class, to: 'self.class', private: true

      def action(action_name = self.action_name)
        action_class(action_name).new(**action_dependencies)
      end

      def action_dependencies
        { repository_class: repository_class, input_class: input_class }
      end

      def action_attributes(input_class = self.input_class)
        params.require(input_class.model_name.param_key).permit(*input_class.attribute_names)
      rescue ActionController::ParameterMissing
        {}
      end

      def action_locals
        { model_class: model_class }
      end
    end
  end
end
