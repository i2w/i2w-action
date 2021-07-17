require 'test_helper'

class I2w::ActionTest < ActiveSupport::TestCase
  test 'action_class_candidates single namespace' do
    assert_equal ['Cars::NewAction', 'NewAction'], I2w::Action.action_class_candidates('Car', :new)
  end

  test 'action_class_candidates 2 namepsaces' do
    assert_equal ['Zackend::Cars::NewAction', 'Zackend::NewAction', 'Cars::NewAction', 'NewAction'],
                 I2w::Action.action_class_candidates('Zackend::Car', :new)
  end

  test 'action_class_candidates 3 namespaces' do
    assert_equal ['Zackend::Cars::Reports::NewAction', 'Zackend::Reports::NewAction', 'Zackend::Cars::NewAction',
                  'Zackend::NewAction', 'Reports::NewAction', 'NewAction'],
                 I2w::Action.action_class_candidates('Zackend::Cars::Report', :new)
  end
end
