# frozen_string_literal: true

require_relative 'controller/crud_actions'

module I2w
  class Action
    # mixin for ActionController::Base
    module Controller
      extend ActiveSupport::Concern

      included do
        extend Repo::Class

        class << self
          extend Memoize

          def repo_class_base_name = controller_path.singularize.classify

          def repo_class_ref(type) = PossiblyNamespacedRepoClassRef.new(repo_class_base_name, type)

          memoize def action_class(action_name)
            PossiblyNamespacedRepoClassRef.new(repo_class_base_name.pluralize, :"#{action_name}_action").lookup
          end
        end

        repo_class_accessor :repository, :input, :model
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
