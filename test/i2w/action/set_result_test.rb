module I2w
  class Action
    class ResultTest < ActiveSupport::TestCase
      class ReturnResult < Action
        include SetResult

        def set_result(result, arg)
          result.arg = arg
          result[:yes, :no] = arg == :foo ? Result.success(arg) : Result.failure(arg)
          result.last = Result.success(:finished)

          side_effects = [] # return value of set_result is ignored
        end
      end

      test "ReturnResult class returns OpenResult, and stop on first failure" do
        actual = ReturnResult.new.call(:foo)
        assert actual.success?
        assert_equal :foo, actual.arg
        assert_equal :foo, actual.yes
        assert_equal :finished, actual.last
        assert_equal(OpenStruct.new(arg: :foo, yes: :foo, last: :finished), actual.value)
        assert_equal({ arg: :foo, yes: :foo, last: :finished }, actual.value.to_h)
        assert_equal({ arg: :foo, yes: :foo, last: :finished }, actual.to_h)

        actual = ReturnResult.new.call(:bar)
        assert actual.failure?
        assert_equal({ arg: :bar }, actual.successes)
        assert_equal({ no: :bar }, actual.failures)
        assert_equal(OpenStruct.new(arg: :bar, no: :bar), actual.failure)
        assert_equal({ arg: :bar, no: :bar }, actual.failure.to_h)
      end
    end
  end
end