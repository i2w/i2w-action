require 'test_helper'

class I2w::ActionTest < ActiveSupport::TestCase
  test 'action_class_candidates' do
    assert_equal ['Cars::NewAction', 'NewAction'], I2w::Action.action_class_candidates('Car', :new)
  end
end
