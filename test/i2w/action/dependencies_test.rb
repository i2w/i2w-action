module I2w
  class Action
    class DependenciesTest < ActiveSupport::TestCase
      class BaseAction < Action
        dependency :foo, -> { 'foo' }
        dependency :bar, 'bar'

        def call = "foo: #{foo}, bar: #{bar}"
      end

      class OtherAction < BaseAction
        dependency :bar, -> { 'BAR' }
      end

      test 'dependency has a default, that can be set via new' do
        assert 'foo: foo, bar: bar', BaseAction.call
        assert 'foo: xxx, bar: bar', BaseAction.new(foo: 'xxx').call
      end

      test 'dependencies are private' do
        assert BaseAction.new.respond_to?(:foo, include_private = true)
        refute BaseAction.new.respond_to?(:foo, include_private = false)
      end

      test 'dependencies have no setters' do
        refute BaseAction.new.respond_to?(:foo=, include_private = true)
      end

      test 'dependencies are inherted, but can be overridden' do
        assert 'foo: foo, bar: BAR', OtherAction.call
        assert 'foo: xxx, bar: yyy', OtherAction.new(foo: 'xxx', bar: 'yyy').call
      end
    end
  end
end