# frozen_string_literal: true

module I2w
  module Action
    # Default implementation of the destroy action
    module Destroy
      def call(id)
        repo.destroy(id)
      end
    end
  end
end
