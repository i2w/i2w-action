# frozen_string_literal: true

module I2w
  module Action
    # default implementation of the create action
    module Create
      def call(input)
        validate(input).and_then { |valid_input| repo.create(valid_input) }
      end
    end
  end
end
