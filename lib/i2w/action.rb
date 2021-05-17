# frozen_string_literal: true

require 'i2w/result'
require 'i2w/repo/class'
require_relative 'stream'
require_relative 'action/version'
require_relative 'action/actions'
require_relative 'action/transaction'

module I2w
  # Base class for actions
  class Action
    extend Repo::Class

    repo_class_accessor :repository, :input, model: -> { module_parent.name.singularize.constantize }

    def self.call(...) = new.call(...)

    def initialize(repository_class: self.class.repository_class, input_class: self.class.input_class)
      @repository_class = repository_class
      @input_class = input_class
    end

    private

    attr_reader :repository_class, :input_class

    # returns a proxy for repository methods, which wraps calls in repo_result,
    # which turns models into success monads, and handles a variety of active record errors as failure monads
    def repo = Repo[repository_class]

    # returns Result.success(valid input) or Result.failure(invalid input)
    def validate(attributes)
      input = input_class.new(attributes)
      input.valid? ? Result.success(input) : Result.failure(input)
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
