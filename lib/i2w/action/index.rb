# frozen_string_literal: true

module I2w
  module Action
    # Default implementation of the index action
    module Index
      def call
        Result.success repo.all
      end
    end
  end
end
