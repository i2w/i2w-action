# frozen_string_literal: true

module I2w
  module Action
    # Default implementation of the update action
    module Update
      def call(id, input)
        validate(input).and_then { |valid_input| repo.update(id, valid_input) }
      end
    end
  end
end
