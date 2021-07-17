require 'test_helper'

class I2w::ActionTest < ActiveSupport::TestCase
  test 'action_class_candidates' do
    assert_equal ['Cars::NewAction', 'NewAction'], I2w::Action.action_class_candidates('Car', :new)
    assert_equal ['Backend::Cars::Reports::NewAction', 'Backend::Reports::NewAction', 'Reports::NewAction', 'NewAction'],
                 I2w::Action.action_class_candidates('Backend::Cars::Report', :new)
  end
end
