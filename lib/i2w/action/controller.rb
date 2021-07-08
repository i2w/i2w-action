# frozen_string_literal: true

require_relative 'controller/crud_actions'

module I2w
  class Action
    module Controller
      extend ActiveSupport::Concern

      included do
        extend Repo::Class

        repo_class_accessor :repository, :input, model: -> { controller_path.singularize.classify.constantize }
      end

      private

      delegate :repository_class, :input_class, :model_class, to: 'self.class', private: true

      def action(action_name = self.action_name)
        action_class(action_name).new(**action_dependencies)
      end

      def action_dependencies
        { repository_class: repository_class, input_class: input_class }
      end

      # TODO: memoize on class with cache based on action_name
      def action_class(action_name)
        candidates = action_class_candidates(action_name)
        candidates.each do |candidate|
          return "#{self.class.module_parent}::#{candidate.classify}".constantize
        rescue NameError
          next
        end
        raise NameError, "Couldn't find action class for #{action_name} #{model_class} in #{candidates}"
      end

      def action_class_candidates(action_name)
        ["#{controller_name}/#{action_name}_action", "#{action_name}_action"]
      end

      def action_attributes(input_class = self.input_class)
        params.require(input_class.model_name.param_key).permit(*input_class.attribute_names)
      end

      def action_locals
        { model_class: model_class }
      end
    end
  end
end
