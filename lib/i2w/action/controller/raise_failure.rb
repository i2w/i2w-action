# frozen_string_literal: true

module I2w
  class Action
    module Controller
      # around filter that raises the failure, useful for hooking into standard rails error handling
      class RaiseFailure
        def self.around(*)
          yield
        rescue I2w::Result::FailureTreatedAsSuccessError => e
          e.raise_failure!
        end
      end
    end
  end
end