require 'test_helper'

ActiveJob::Base.logger = Logger.new(IO::NULL)

module I2w
  class Action
    class ControllerTest < ActiveSupport::TestCase
      test 'RaiseFailure filter raises the failure if it is an exception' do
        assert_raises(ZeroDivisionError) do
          Controller::RaiseFailure.around(nil, -> { I2w::Result.wrap { 1/0 }.value })
        end

        assert_raises(I2w::Result::FailureTreatedAsSuccessError) do
          Controller::RaiseFailure.around(nil, -> { I2w::Result.failure(:foo).value })
        end

        assert_equal :foo, Controller::RaiseFailure.around(nil, -> { I2w::Result.success(:foo).value })
      end
    end
  end
end