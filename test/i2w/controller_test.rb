require 'test_helper'

require 'i2w/action/controller'

class I2w::ControllerTest < ActiveSupport::TestCase
  class Controller
    include I2w::Action::Controller
  end

  class FooController < Controller; end

  module Backend
    class FooController < Controller; end
  end

  test 'group_name_candidates' do
    assert_equal ['Backend::Foo', 'Foo'], Controller.group_name_candidates('Backend::Foo')
  end
end
