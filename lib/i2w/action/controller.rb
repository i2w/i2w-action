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

          def group_lookup(type, *args)
            group_name_candidates(group_name).each do |group_name|
              result = Repo.lookup(group_name, type, *args)
              return result if result.is_a?(Class)
            end
            raise NameError, "Couldn't find #{[type, *args].join(', ')} searched: #{group_name_candidates(group_name).join(', ')}"
          end

          def group_name_candidates(group_name)
            parts = group_name.split('::')
            parts.length.times.map { parts[_1..].join('::') }
          end
        end
      end

      delegate :repository_class, :input_class, :model_class, :action_class, to: 'self.class', private: true

      def action(action_name = self.action_name) = action_class(action_name).new(**action_dependencies)

      def action_dependencies
        { repository_class: repository_class, input_class: input_class }
      end

      def action_attributes(input_class = self.input_class)
        params.require(input_class.model_name.param_key).permit(*input_class.attribute_names)
      rescue ActionController::ParameterMissing
        {}
      end

      def action_locals = { model_class: model_class }
    end
  end
end
