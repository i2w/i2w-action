# frozen_string_literal: true

require 'i2w/result'
require_relative 'action/version'
require_relative 'action/actions'
require_relative 'action/repo_result'

module I2w
  # Base class for actions
  class Action
    def initialize(repo_class: self.class.repo_class, input_class: self.class.input_class)
      @repo_class = repo_class
      @input_class = input_class
    end

    private

    attr_reader :repo_class, :input_class

    # returns a proxy for repository methods, wrapped in repo_result, which turns models into success monads,
    # and handles a variety of active record errors as failure monads
    def repo = @repo ||= RepoResult::Proxy.new(repo_class)

    # return the value of the block in a result monad, handling repo errors as failure monads
    def repo_result(...) = RepoResult.new.call(...)

    # returns Result.success(valid input) or Result.failure(:invalid, errors)
    def validate(input)
      return Result.success(input) if input.valid?

      Result.failure(:invalid, input.errors)
    end

    # wrap in a repo_class transaction, and additionally rollback if the result is a failure
    def transaction
      result = nil
      repo_class.transaction do
        result = yield
        repo_class.rollback! if result.failure?
      end
      result
    end

    class << self
      def call(...) = new.call(...)

      attr_writer :repo_class, :input_class

      def repo_class = @repo_class ||= associated_class('Repo')

      def input_class = @input_class ||= associated_class('Input')

      private

      # The model name is assumed to be the module parent, singularized
      def associated_class(suffix)
        "#{module_parent.name.singularize}#{suffix}".constantize
      end
    end
  end
end
