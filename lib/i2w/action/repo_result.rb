# frozen_string_literal: true

require 'active_model/errors'
require 'i2w/result'

module I2w
  class Action
    # Utility to wrap an active record operation in a result.
    # It converts some active record errors into failures with useful errors
    class RepoResult
      # yields the block and returns the result in Result.success monad
      # Rescues a variety of active record errors and returns appropriate Result.failure monads
      def call
        Result.success yield
      rescue ActiveRecord::RecordNotFound => e
        not_found_failure(e)
      rescue ActiveRecord::NotNullViolation => e
        presence_failure(e)
      rescue ActiveRecord::RecordNotUnique => e
        uniqueness_failure(e)
      end

      private

      def not_found_failure(_exception)
        Result.failure :not_found, error(:id, :not_found)
      end

      def presence_failure(exception)
        # currently only works in postgres
        attribute = exception.message[/column "(\w+)"/, 1] || 'unknown'
        Result.failure :db_constraint, error(attribute, :blank)
      end

      def uniqueness_failure(exception)
        # currently only works for postgres
        attribute = exception.message[/Key .*?(\w+)\)?=/, 1] || 'unknown'
        Result.failure :db_constraint, error(attribute, :taken)
      end

      def error(attribute, error)
        @errors ||= ActiveModel::Errors.new(Object.new)
        @errors.add(attribute, error)
        @errors
      end

      class Proxy
        def initialize(repo_class)
          @repo_class = repo_class
        end

        def method_missing(...)
          RepoResult.new.call { @repo_class.send(...) }
        end

        def respond_to_missing?(...)
          @repo_class.respond_to_missing?(...)
        end
      end
    end
  end
end
