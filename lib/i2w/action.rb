# frozen_string_literal: true

require 'i2w/result'
require 'i2w/repo'
require_relative 'stream'
require_relative 'action/callbacks'
require_relative 'action/call_later'
require_relative 'action/set_result'
require_relative 'action/controller'
require_relative 'action/version'
require_relative 'action/actions'
require_relative 'action/stream_action'

module I2w
  # Base class for actions
  class Action
    include I2w::Result
    include SetResult
    include Callbacks
    extend CallLater

    Repo.register_class self, :action, accessors: %i[repository input] do
      def group_name = name.deconstantize.singularize

      def from_group_name(group_name, action_name)
        "#{group_name.pluralize}::#{action_name.to_s.camelize}Action".constantize
      end
    end

    class << self
      def call(...) = new.call(...)
    end

    def initialize(repository_class: self.class.repository_class, input_class: self.class.input_class)
      @repository_class = repository_class
      @input_class = input_class
    end

    private

    attr_reader :repository_class, :input_class

    # returns a proxy for repository methods, which wraps calls in repo_result,
    # which turns models into success monads, and handles a variety of active record errors as failure monads
    def repo(klass = repository_class) = Repo.result_proxy(klass, input_class)

    # pass attributes, or an input object
    # returns Result.success(valid input) or Result.failure(invalid input)
    def validate(input)
      input = input_class.new(input) unless input.respond_to?(:valid?)
      input.valid? ? success(input) : failure(input)
    end

    # yield in a repo_class transaction, and automatically rollback if the result is a failure
    def transaction
      result = nil
      repository_class.transaction do
        result = yield
        repository_class.rollback! if result.failure?
      end
      result
    end
  end
end
