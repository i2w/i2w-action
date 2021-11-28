# frozen_string_literal: true

require_relative 'controller/crud_actions'

module I2w
  class Action
    # mixin for Rails controllers to help with using actions
    module Controller
      extend ActiveSupport::Concern

      included do
        Repo.register_class self, accessors: %i[repository input model action] do
          def group_name = name.sub(/Controller\z/, '').singularize
        end
      end

      delegate :repository_class, :input_class, :model_class, :action_class, to: 'self.class', private: true

      private

      # instantiate (with #dependencies) an Action class based on conventional group naming
      def action(action_name) = action_class(action_name).new(**dependencies)

      # call the action, and render the result, use this when you don;t want to handle failure
      def render_action(action_name, template_name = action_name, **kwargs)
        render template_name.to_s, locals: { **locals, **action(action_name).call(**kwargs) }
      end

      # the arguments used to instantiate an Action class for this controller
      def dependencies = { repository_class: repository_class, input_class: input_class }

      # given an input class, return the attributes as a hash from #params for the input
      def attributes(input_class = self.input_class)
        params.require(input_class.model_name.param_key)
              .permit(*input_class.attribute_names)
              .to_h.symbolize_keys

      rescue ActionController::ParameterMissing
        {}
      end

      # slice the given keys from #params, with optional defaults filled in (returns hash)
      def parameters(*keys, **defaults)
        parameters = params.permit(*keys, *defaults.keys)
                           .to_h.symbolize_keys

        { **defaults, **parameters }
      end

      # override this to add to the locals that are passed to render in #render_action
      def locals = {}
    end
  end
end
