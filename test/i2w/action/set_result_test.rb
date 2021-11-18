module I2w
  class Action
    class ResultTest < ActiveSupport::TestCase
      class ReturnResult < Action
        include SetResult

        attr_reader :success_side_effect

        def set_result(result, arg:)
          result.arg = arg
          result[:yes, :no] = arg == :foo ? Result.success(arg) : Result.failure(arg)
          result.last = Result.success(:finished)

          @success_side_effect = true # return value of set_result is ignored, but side effects can occur
        end
      end

      test "ReturnResult class returns OpenResult, and stop on first failure" do
        action = ReturnResult.new
        actual = action.call(arg: :foo)
        assert actual.success?
        assert_equal :foo, actual.arg
        assert_equal :foo, actual.yes
        assert_equal :finished, actual.last
        assert_equal({ arg: :foo, yes: :foo, last: :finished }, actual.value.to_h)
        assert_equal({ arg: :foo, yes: :foo, last: :finished }, actual.to_h)
        assert action.success_side_effect

        action = ReturnResult.new
        actual = action.call(arg: :bar)
        assert actual.failure?
        assert_equal({ arg: :bar }, actual.successes)
        assert_equal({ no: :bar }, actual.failures)
        assert_equal({ arg: :bar, no: :bar }, actual.failure.to_h)
        refute action.success_side_effect
      end
    end
  end
end