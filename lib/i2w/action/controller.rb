# frozen_string_literal: true

require_relative 'controller/crud_actions'

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

      def action(action_name = self.action_name) = action_class(action_name).new(**dependencies)

      def dependencies
        { repository_class: repository_class, input_class: input_class }
      end

      def attributes(input_class = self.input_class)
        params.require(input_class.model_name.param_key).permit(*input_class.attribute_names)
      rescue ActionController::ParameterMissing
        {}
      end

      def locals = { model_class: model_class }

      def redirect_to_model_or_index(model)
        redirect_to url_for(respond_to?(:show) ? { id: model.id } : { action: :index })
      end
    end
  end
end
