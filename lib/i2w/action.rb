# frozen_string_literal: true

require 'i2w/data_object'
require 'i2w/result'
require 'i2w/repo'

require_relative 'action/callbacks'
require_relative 'action/call_later'
require_relative 'action/set_result'
require_relative 'action/controller'
require_relative 'action/version'
require_relative 'action/actions'

module I2w
  # Base class for actions
  class Action
    NoArg  = I2w::NoArg
    Result = I2w::Result

    include Result
    include SetResult
    include Callbacks
    extend CallLater
    extend Dependencies

    dependency :repo,        class_lookup { _1.deconstantize.singularize + 'Repo' }
    dependency :input_class, class_lookup { _1.deconstantize.singularize + 'Input' }

    def self.call(...) = new.call(...)

    private

    # pass attributes, or an input object
    # returns Result.success(valid input) or Result.failure(invalid input)
    def validate(input)
      input = input_class.new(input) unless input.respond_to?(:valid?)
      input.valid? ? success(input) : failure(input)
    end
  end
end
