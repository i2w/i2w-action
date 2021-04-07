# frozen_string_literal: true

module I2w
  module Action
    # Default implementation of the new action
    module Show
      def call(id)
        repo.find(id)
      end
    end
  end
end
