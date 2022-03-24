require 'test_helper'

ActiveJob::Base.logger = Logger.new(IO::NULL)

module I2w
  class Action
    class CallLaterTest < ActiveSupport::TestCase
      include ActiveJob::TestHelper

      setup do
        SideEffects.clear
      end

      class SideEffects
        def self.clear = @side_effects = nil

        def self.push(arg)
          @side_effects ||= []
          @side_effects.push(arg)
        end

        def self.to_a = @side_effects
      end

      class CallLaterAction < Action
        dependency :dep, 'default'

        def call(arg)
          SideEffects.push([:call_later, arg, dep])
          SubsidiaryAction.call_later(arg)
          success(:ok)
        end
      end

      class CallAsyncAction < Action
        def call(arg)
          SideEffects.push([:call_async, arg])
          SubsidiaryAction.call_async(arg)
          success(:ok)
        end
      end

      class SubsidiaryAction < Action
        def call(arg)
          SideEffects.push([:subsidiary, arg])
          success(:ok)
        end
      end

      test 'call_later' do
        perform_enqueued_jobs do
          CallLaterAction.call_later(:foo)
        end
        assert_equal [[:call_later, :foo, 'default'], [:subsidiary, :foo]], SideEffects.to_a
      end

      test 'call_later setting dependencies' do
        perform_enqueued_jobs do
          CallLaterAction.call_later(:foo, dependencies: { dep: 'set' })
        end
        assert_equal [[:call_later, :foo, 'set'], [:subsidiary, :foo]], SideEffects.to_a
      end

      test 'nested call later calls only enqueues one job' do
        assert_enqueued_jobs 1 do
          CallLaterAction.call_later(:foo)
        end

        perform_enqueued_jobs
        assert_enqueued_jobs 0
      end

      test 'call_async' do
        perform_enqueued_jobs do
          CallAsyncAction.call_async(:foo)
        end
        assert_equal [[:call_async, :foo], [:subsidiary, :foo]], SideEffects.to_a
      end

      test 'nested call async calls enqueues multiple jobs' do
        assert_enqueued_jobs 1 do
          CallLaterAction.call_async(:foo)
        end

        perform_enqueued_jobs
        assert_enqueued_jobs 1
      end
    end
  end
end