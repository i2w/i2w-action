require 'i2w/data_object'

require_relative 'streamable/lookup'
require_relative 'streamable/model'
require_relative 'streamable/parent'

module I2w
  # Given a model or a model class, a streamable implements the interface used by Stream and Stream::View
  class Streamable
    class << self
      def lookup(...) = Lookup.call(...)
      alias [] lookup

      def model(&block)
        class_eval "class #{self}::Model < #{superclass}::Model; end", __FILE__, __LINE__ unless self == Streamable
        self::Model.class_eval(&block) if block
        self::Model
      end

      def parent(&block)
        class_eval "class #{self}::Parent < #{superclass}::Parent; end", __FILE__, __LINE__ unless self == Streamable
        self::Parent.class_eval(&block) if block
        self::Parent
      end

      # def inherited(subclass)
      #   super(subclass)
      #   subclass.const_set('Model', Class.new(self::Model))
      #   subclass.const_set('Parent', Class.new(self::Parent))
      # end

      def stream_prefix = [Rails.application.railtie_name]

      def renderer = ActionController::Base
    end
  end
end
