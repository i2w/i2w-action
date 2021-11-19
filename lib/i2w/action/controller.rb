# frozen_string_literal: true

require_relative 'controller/crud_actions'
require_relative 'controller/raise_failure'

module I2w
  class Action
    # mixin for ActionController::Base
    module Controller
      extend ActiveSupport::Concern

      included do
        Repo.register_class self, accessors: %i[repository input model action] do
          def group_name = name.sub(/Controller\z/, '').singularize
        end
      end

      delegate :repository_class, :input_class, :model_class, :action_class, to: 'self.class', private: true

      private

      def action(action_name) = action_class(action_name).new(**dependencies)

      def render_action(action_name, ...)
        render action_name.to_s, locals: { **locals, **action(action_name).call(...) }
      end

      def dependencies = { repository_class: repository_class, input_class: input_class }

      def attributes(input_class = self.input_class)
        params.require(input_class.model_name.param_key).permit(*input_class.attribute_names).to_h.symbolize_keys
      rescue ActionController::ParameterMissing
        {}
      end

      def parameters(*keys, **defaults) = { **defaults, **params.permit(*keys).to_h.symbolize_keys }

      def locals = {}
    end
  end
end
