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
      # will instantiate a CreatePersonAction as follows
      #
      #   action = CreatePersonAction.new(repo: PersonRepo, input_class: PersonInput)
      #
      # and call it with the arguments, ie
      #
      #   action.call(input)
      module DefaultAction
        extend ActiveSupport::Concern

        private

        delegate :repo, :input_class, :model_name, to: 'self.class'

        def default_action(...)
          action_class.new(repo: repo, input_class: input_class).call(...)
        end

        # TODO: memoize on class with cache based on action_name
        def action_class
          ["#{action_name}_#{model_name}_action", "#{action_name}_action"].each do |candidate|
            return "#{self.class.module_parent}::#{candidate.classify}".constantize
          rescue NameError
            next
          end
          raise NameError, "Couldn't find action class for #{action_name} #{model_name}"
        end

        def default_input
          input_class.new(**default_permitted_params.to_h.symbolize_keys)
        end

        def default_permitted_params
          params.require(input_class.model_name.param_key).permit(*input_class.attribute_names)
        end

        # class interface
        module ClassMethods
          def model_name
            @model_name ||= controller_name.singularize.to_sym
          end

          def repo
            @repo ||= associated_class('Repo')
          end

          def input_class
            @input_class ||= associated_class('Input')
          end

          private

          attr_writer :model_name, :repo, :input_class

          def associated_class(suffix)
            "#{module_parent}::#{model_name.to_s.camelize}#{suffix}".constantize
          end
        end
      end
    end
  end
end
