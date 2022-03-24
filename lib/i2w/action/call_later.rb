require 'active_job'

module I2w
  class Action
    # extend into Actions to add #call_later, #call_async methods to the action, which performs the action via active job
    module CallLater
      # Nested #call_later calls will run inside the same process (will not schedule new action jobs)
      def call_later(*args, dependencies: {}, **kwargs)
        if Thread.current[:within_call_later]
          new(**dependencies).call(*args, **kwargs)
        else
          CallLaterJob.perform_later(self, dependencies, *args, **kwargs)
        end
      end

      # Nested #call_async calls will always schedule a new active job
      def call_async(*args, dependencies: {}, **kwargs)
        CallAsyncJob.perform_later(self, dependencies, *args, **kwargs)
      end

      class CallLaterJob < ActiveJob::Base
        def perform(action_class, dependencies, ...)
          prev_call_later, Thread.current[:within_call_later] = Thread.current[:within_call_later], true
          action_class.new(**dependencies).call(...).value
        ensure
          Thread.current[:within_call_later] = prev_call_later
        end
      end

      class CallAsyncJob < ActiveJob::Base
        def perform(action_class, dependencies, ...)
          action_class.new(**dependencies).call(...).value
        end
      end
    end
  end
end