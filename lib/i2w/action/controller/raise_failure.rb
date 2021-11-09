# frozen_string_literal: true

module I2w
  class Action
    module Controller
      # around filter that raises the failure, useful for hooking into standard rails error handling
      class RaiseFailure
        def self.around(_controller, action)
          action.call
        rescue I2w::Result::FailureTreatedAsSuccessError => e
          e.raise!
        end
      end
    end
  end
end