# frozen_string_literal: true

require 'i2w/human'
require 'i2w/no_arg'
require_relative 'controller/crud_actions'
require_relative 'controller/result_match_filter'

module I2w
  class Action
    # mixin for Rails controllers to help with using actions
    module Controller
      NoArg = I2w::NoArg

      extend ActiveSupport::Concern

      included do
        extend Dependencies

        # use result { |on| on.failure { ... } } to declare how a controller should handle unmatched results
        around_action ResultMatchFilter

        # we need the input class to decide how to pull attributes out of params
        dependency :input_class, class_lookup { _1.sub(/Controller\z/, '').singularize + 'Input' }

        # we provide dependencies to actions via this see #provide_action_dependency
        @action_dependencies = Dependencies::Container.new

        # handlers declare how to handle unmatched results
        @result_match_handlers = []
      end

      module ClassMethods
        # action dependencies are resolved using the controller instance, and passed to the action
        attr_reader :action_dependencies, :result_match_handlers

        protected

        def provide_action_dependency(name, default = name) = action_dependencies.add(name, default)

        # class level declaration to handle unmatched results from actions
        def on_result(&block) = result_match_handlers << block

        private

        def inherited(subclass)
          super
          subclass.instance_variable_set :@action_dependencies, action_dependencies.dup
          subclass.instance_variable_set :@result_match_handlers, result_match_handlers.dup
        end
      end

      def h(...) = I2w::Human.call(...)

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
        parameters = params.permit(*keys, *defaults.keys).to_h.symbolize_keys
        { **defaults, **parameters }
      end

      protected

      # instantiate (with #dependencies) an Action class based on conventional group naming
      def action(action_name) = action_class(action_name).new(**action_dependencies)

      # call the action, and yield the block to success, use this when you don't need to handle failure
      def call_action(action_name, **kwargs, &success)
        on_result action(action_name).call(**kargs) do |on|
          on.success(&success)
        end
      end

      # call the action, and render the result, use this when you don't need to handle failure
      def render_action(action_name, template_name = action_name, **kwargs)
        render_result template_name, action(action_name).call(**kwargs)
      end

      # render successful result with the template_name
      def render_result(template_name, result)
        on_result result do |on|
          on.success { render_template template_name, _1 }
        end
      end

      # render the template with an optional argument, which responds to #to_hash, with controller specified locals
      def render_template(template_name, hashy = {})
        render template_name.to_s, locals: { **locals, **hashy }
      end

      # override this to add to the locals that are passed to render in #render_action
      def locals = {}

      # use #on_result in an action to respond differently to success or failure results
      #
      # any unhandled results will result in Result::MatchNotFoundError, but you can declare on the class
      # how to handle them
      #
      # on_result action(:create).call(input: attributes) do |on|
      #   on.success         { redirect_to _1.widget }
      #   on.failure(:input) { render 'new', locals: _1 }
      #   on.failure         { render 'error', locals: _1 }
      # end
      def on_result(...) = I2w::Result.match(...)

      private

      def action_class(action_name) = action_class_lookup(action_name).call(self.class)

      # by default, UsersController#new will correspond to Users::NewAction, override this method with your
      # own scheme if necessary
      def action_class_lookup(action_name)
        ClassLookup.new { _1.sub(/Controller\z/, "::#{action_name.to_s.classify}Action") }
      end

      # the arguments used to instantiate an Action class for this controller, see #provide_action_dependency
      def action_dependencies = self.class.action_dependencies.resolve_all(self)
    end
  end
end
