module I2w
  class Action
    module Callbacks
      def self.included(klass) = klass.extend(ClassMethods)

      def call(...) = super.tap { _1.success? ? run_callbacks(:success, _1) : run_callbacks(:failure, _1) }

      private

      def run_callbacks(type, result) = self.class.send("#{type}_callbacks").each { run_callback(_1, result) }

      def run_callback(callback, result)
        callback = method(callback) if callback.is_a?(Symbol)
        callback = callback.method(:call) unless callback.respond_to?(:to_proc)

        callback.arity == 1 ? instance_exec(result, &callback) : callback.call(result, self)
      end

      module ClassMethods
        def inherited(subclass)
          super
          subclass.instance_variable_set(:@success_callbacks, success_callbacks.dup)
          subclass.instance_variable_set(:@failure_callbacks, failure_callbacks.dup)
        end

        def success_callbacks = @success_callbacks ||= []

        def failure_callbacks = @failure_callbacks ||= []

        private

        def on_success(*callbacks, &block) = success_callbacks.concat([*callbacks, *block])

        def on_failure(*callbacks, &block) = failure_callbacks.concat([*callbacks, *block])
      end
    end
  end
end