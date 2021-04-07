# frozen_string_literal: true

module I2w
  module Action
    # Default implementation of the new action
    module New
      def call
        Result.success input_class.new
      end
    end
  end
end



