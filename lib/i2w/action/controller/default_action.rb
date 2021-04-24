# frozen_string_literal: true

module I2w
  class Action
    module Controller
      # provides support for looking up and using default (conventionally named) Actions in controllers
      #
      # eg.  In PeopleController#create
      #
      #   default_action(input)
      #
      # will instantiate an action as follows:
      #
      #   action = People::CreateAction.new(repo: PersonRepo, input_class: PersonInput)
      #
      # and call it with the arguments, i.e.
      #
      #   action.call(input)
      module DefaultAction
        extend ActiveSupport::Concern

        private

        delegate :repo_class, :input_class, :model_name, to: 'self.class'

        def default_action(...)
          action_class.new(repo_class: repo_class, input_class: input_class).call(...)
        end

        # TODO: memoize on class with cache based on action_name
        def action_class
          action_class_candidates.each do |candidate|
            return "#{self.class.module_parent}::#{candidate.classify}".constantize
          rescue NameError
            next
          end
          raise NameError, "Couldn't find action class for #{action_name} #{model_name} in #{action_class_candidates}"
        end

        def action_class_candidates
          ["#{controller_name}/#{action_name}_action", "#{action_name}_action"]
        end

        def default_input
          input_class.new(default_permitted_params)
        end

        def default_permitted_params
          params.require(input_class.model_name.param_key).permit(*input_class.attribute_names)
        end

        # class interface
        module ClassMethods
          def model_name = @model_name ||= controller_name.singularize.to_sym

          def repo_class = @repo_class ||= associated_class('Repo')

          def input_class = @input_class ||= associated_class('Input')

          private

          attr_writer :model_name, :repo_class, :input_class

          def associated_class(suffix)
            "#{module_parent}::#{model_name.to_s.camelize}#{suffix}".constantize
          end
        end
      end
    end
  end
end
