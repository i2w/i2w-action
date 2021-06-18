require 'i2w/data_object'

require_relative 'streamable/lookup'
require_relative 'streamable/child'
require_relative 'streamable/parent'
require_relative 'streamable/belongs_to'

module I2w
  # Given a model or a model class, a streamable implements the interface used by Stream and Stream::View
  class Streamable
    extend BelongsTo

    class << self
      def lookup(...) = Lookup.call(...)
      alias [] lookup

      def stream_prefix = [Rails.application.railtie_name]

      def renderer = ActionController::Base

      private

      def child(&block) = self::Child.tap { |m| m.class_eval(&block) if block }

      def parent(&block) = self::Parent.tap { |m| m.class_eval(&block) if block }

      # we subclass the Model and Parent inner classes each time a new Streamable is inherited
      def inherited(subclass)
        super
        subclass.const_set(:Child, Class.new(subclass.superclass.const_get(:Child)))
        subclass.const_set(:Parent, Class.new(subclass.superclass.const_get(:Parent)))
      end
    end
  end
end
