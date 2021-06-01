require 'i2w/data_object'

require_relative 'streamable/dom_id'
require_relative 'streamable/lookup'
require_relative 'streamable/streamable_methods'
require_relative 'streamable/parent'

module I2w
  # Given a model or a model class, a streamable implements the interface used by Stream and Stream::View
  class Streamable < DataObject::Mutable
    include StreamableMethods

    class << self
      def lookup(...) = Lookup.call(...)
      alias [] lookup
    end

    attr_reader :model

    def initialize(model, **attributes)
      super(**attributes)
      @model = model
    end

    def parent = @parent ||= new_parent

    def stream_from = parent.stream_from

    def stream_prefix = parent.stream_prefix

    def renderer = parent.renderer

    def parent_id(prefix = nil) = parent.target_id(prefix)

    def target(prefix = nil) = [*prefix, model]

    def locals = { model.model_name.element.to_sym => model, model: model, model_class: model.class, **attributes }

    def partial(prefix = nil)
      "#{model.model_name.collection}/#{prefix}#{prefix ? '_' : ''}#{model.model_name.element}"
    end

    private

    def new_parent = Streamable.lookup(model.class)
  end
end
