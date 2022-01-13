# frozen_string_literal: true

require 'test_helper'
require 'action_controller'

module I2w
  class Action
    class ControllerTest < ActiveSupport::TestCase
      class AbstractController < ActionController::Base
        include Action::Controller
      end

      class FooController < AbstractController
        def failing_foo
          on_result Result.failure('foo') do |on|
            on.success { render inline: "success #{_1}" }
          end
        end
      end

      class FooWithHandlerController < FooController
        on_result do |on|
          on.failure { render inline: "failing #{_1} handled" }
        end
      end

      class FooInput < Input
        attribute :bar
        attribute :baz

        validates :bar, presence: true
        validates :baz, presence: true
      end

      test 'input_class dependency' do
        assert_equal FooInput, FooController.new.send(:input_class)
      end

      test '#attributes uses input_class to extract parameters from params' do
        controller = FooController.new
        controller.params = { unknown: '1', i2w_action_controller_test_foo_input: { danger: 'xxx', bar: 'bar', baz: 'baz' } }
        assert_equal({ bar: "bar", baz: "baz" }, controller.send(:attributes))
      end

      test '#h' do
        assert_equal "Errors: Bar can't be blank, Baz can't be blank",
                     FooController.new.send(:h, FooInput.new.tap(&:valid?).errors)
      end

      test 'NoArg is in scope' do
        assert_equal FooController::NoArg, I2w::NoArg
      end

      class FooControllerTest < ActionController::TestCase
        setup do
          @routes = ActionDispatch::Routing::RouteSet.new.tap do
            _1.draw { get '/failing_foo' => 'i2w/action/controller_test/foo#failing_foo' }
          end
        end

        test '#match in action raises MatchNotFoundError if not match is found' do
          assert_raises Result::MatchNotFoundError do
            get :failing_foo
          end
        end
      end

      class FooWithHandlerControllerTest < ActionController::TestCase
        setup do
          @routes = ActionDispatch::Routing::RouteSet.new.tap do
            _1.draw { get '/failing_foo' => 'i2w/action/controller_test/foo_with_handler#failing_foo' }
          end
        end

        test '#match in action can be handled by controller level match_not_found' do
          get :failing_foo
          assert_equal "failing foo handled", response.body
        end
      end
    end
  end
end