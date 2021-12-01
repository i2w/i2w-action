# frozen_string_literal: true

module I2w
  class Action
    # extension for class level dependencies declaration
    module Dependencies
      def self.extended(klass)
        klass.instance_variable_set :@dependencies, {}
      end

      def inherited(subclass)
        super
        subclass.instance_variable_set :@dependencies, dependencies.dup
      end

      attr_reader :dependencies

      def resolve_dependencies(obj, **override)
        (unknown = override.keys - dependencies.keys).any? and raise ArgumentError, "unknown: #{unknown.join(', ')}"
        dependencies.to_h do |k, v|
          [k, override.fetch(k) { v.respond_to?(:call) ? obj.instance_exec(&v) : v }]
        end
      end

      private

      def dependency(name, default)
        dependencies[name] = default
        private attr_reader name
      end
    end
  end
end