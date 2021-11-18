require 'test_helper'

module I2w
  class Action
    class CallbacksTest < ActiveSupport::TestCase
      class OnSuccessClass
        def self.call(result, action)
          action.side_effects << [:class, result.bar, action]
        end
      end

      class CallbacksAction < Action
        def side_effects = @side_effects ||= []

        on_success :success_method, OnSuccessClass, ->(r, a) { a.side_effects << [:lambda, r.bar, a] }

        on_failure do
          side_effects << [:block, _1.failure.error]
        end

        on_success do
          side_effects << [:block, _1.bar]
        end

        def success_method(result)
          side_effects << [:method, result.bar]
        end
      end

      class FooAction < CallbacksAction
        def set_result(result, arg:)
          result.has_foo = true if arg.include?('foo')
          result[:bar, :error] = bar_in_arg(arg)
          result[:last] = true
        end

        def bar_in_arg(arg)
          arg.include?('bar') ? success(arg) : failure('no bar')
        end
      end

      test 'successful action with callbacks' do
        action = FooAction.new
        result = action.call(arg: 'foobar')

        assert result.success?
        assert OpenStruct.new(has_foo: true, bar: 'foobar', last: true), result.value
        assert [[:method, 'foobar'], [:class, 'foobar', action], [:lambda, 'foobar', action], [:block, 'foobar']], action.side_effects
      end

      test 'failed action with callbacks' do
        action = FooAction.new
        result = action.call(arg: 'foo')

        refute result.success?
        assert OpenStruct.new(has_foo: true, error: 'no bar'), result.failure
        assert [[:block, 'foo']], action.side_effects
      end
    end
  end
end