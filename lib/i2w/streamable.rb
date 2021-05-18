require_relative 'streamable/dom_id'
require_relative 'streamable/lookup'
require_relative 'streamable/streamable_methods'
require_relative 'streamable/parent'

module I2w
  # Given a model or a model class, a streamable implements the interface used by Stream and Stream::View
  class Streamable
    include StreamableMethods

    class << self
      def lookup(...) = Lookup.call(...)
      alias [] lookup
    end

    attr_reader :model

    def initialize(model) = @model = model

    def parent = @parent ||= new_parent

    def stream_from = parent.stream_from

    def parent_id(prefix = nil) = parent.target_id(prefix)

    def target(prefix = nil) = [*prefix, model]

    def locals = { model.model_name.element.to_sym => model }

    def partial(prefix = nil)
      "#{model.model_name.collection}/#{prefix}#{prefix ? '_' : ''}#{model.model_name.element}"
    end

    private

    def new_parent = Parent.new(model.class)
  end
end
