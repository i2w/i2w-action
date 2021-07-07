# frozen_string_literal: true

require 'i2w/result'
require 'i2w/repo/class'
require_relative 'stream'
require_relative 'action/version'
require_relative 'action/actions'
require_relative 'action/transaction'
require_relative 'action/stream_action'

module I2w
  # Base class for actions
  class Action
    extend Repo::Class

    repo_class_accessor :repository, :input, model: -> { lookup_namespaced_class(module_parent.name.singularize) }

    class << self
      def call(...) = new.call(...)

      def lookup_namespaced_class(name)
        parts = name.split('::')
        candidates = parts.length.times.map { "#{parts[_1..].join('::')}" }
        candidates.each do |candidate|
          return candidate.constantize
        rescue NameError
          nil
        end
        raise NameError, "couldn't find class, searched: #{candidates.join(', ')}"
      end
    end

    def initialize(repository_class: self.class.repository_class, input_class: self.class.input_class)
      @repository_class = repository_class
      @input_class = input_class
    end

    private

    attr_reader :repository_class, :input_class

    # returns a proxy for repository methods, which wraps calls in repo_result,
    # which turns models into success monads, and handles a variety of active record errors as failure monads
    def repo(klass = repository_class) = Repo.result_proxy(klass)

    # returns Result.success(valid input) or Result.failure(invalid input)
    # if id is given, and the result is a failure, then return Result.failure(invalid input with model)
    def validate(attributes, id = nil)
      input = input_class.new(attributes)

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
