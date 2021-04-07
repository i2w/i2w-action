# frozen_string_literal: true

require 'i2w/result'
require_relative 'action/version'

module I2w
  # Base class for actions, provides #repo, #input_class, #validate, and #transaction private API methods for
  # use in #call method
  class Action
    def initialize(repo: self.class.repo, input_class: self.class.input_class)
      @repo = repo
      @input_class = input_class
    end

    private

    attr_reader :repo, :input_class

    # returns Result.success(valid input) or Result.failure(:invalid, errors)
    def validate(input)
      return Result.success(input) if input.valid?

      Result.failure(:invalid, input.errors)
    end

    # wrap in a repo transaction, and additionally rollback if the result is a failure
    def transaction
      result = nil
      repo.transaction do
        result = yield
        repo.rollback! if result.failure?
      end
      result
    end

    class << self
      def call(...)
        new.call(...)
      end

      attr_writer :action_name, :repo, :input_class

      def action_name
        @action_name ||= default_action_name
      end

      def repo
        @repo ||= associated_class('Repo')
      end

      def input_class
        @input_class ||= associated_class('Input')
      end

      private

      # By default, the action name is the first word of the demodulized class name, as a symbol
      def default_action_name
        name.demodulize.underscore.split('_').first.to_sym
      end

      # Remove the action_name and replace Action with the suffix
      def associated_class(suffix)
        *nesting, name = self.name.split('::')
        name = name.sub(/\A#{action_name.to_s.camelize}/, '')
        name = name.sub(/Action\z/, suffix)
        [*nesting, name].join('::').constantize
      end
    end
  end
end
