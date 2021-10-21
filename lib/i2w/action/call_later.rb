require 'active_job'

module I2w
  class Action
    # extend into Actions to add #call_later, #call_async methods to the action, which performs the action via active job
    module CallLater
      def within_call_later? = Thread.current[:within_call_later]

      # Nested #call_later calls will run inside the same process (will not schedule new action jobs)
      def call_later(...) = within_call_later? ? call(...) : CallLaterJob.perform_later(self, ...)

      # Nested #call_async calls will always schedule a new active job
      def call_async(...) = CallAsyncJob.perform_later(self, ...)

      class CallLaterJob < ActiveJob::Base
        def perform(action_class, ...)
          prev_call_later, Thread.current[:within_call_later] = Thread.current[:within_call_later], true
          action_class.call(...).value
        ensure
          Thread.current[:within_call_later] = prev_call_later
        end
      end

      class CallAsyncJob < ActiveJob::Base
        def perform(action_class, ...) = action_class.call(...).value
      end
    end
  end
end