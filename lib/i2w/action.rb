# frozen_string_literal: true

require 'i2w/result'
require 'i2w/repo/base'
require_relative 'stream'
require_relative 'action/version'
require_relative 'action/actions'
require_relative 'action/transaction'
require_relative 'action/stream_action'

module I2w
  # Base class for actions
  class Action
    extend Repo::Base.extension :action,
                                accessors: %i[repository input],
                                search_namespaces: true,
                                to_base: proc { _1.deconstantize.singularize },
                                from_base: proc { "#{_1.pluralize}::#{_2.to_s.camelize}Action" }

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
    def repo(klass = repository_class) = Repo.for(klass, input_class)

    # pass attributes, or an input object
    # returns Result.success(valid input) or Result.failure(invalid input)
    # if id is given, and the result is a failure, then return Result.failure(invalid input with model)
    def validate(input, id = nil)
      input = input_class.new(input) unless input.respond_to?(:valid?)

      return Result.success(input) if input.valid?
      return Result.failure(input) if id.nil?

      repo.find(id: id).and_then { Result.failure Input::WithModel.new(input, _1) }
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
