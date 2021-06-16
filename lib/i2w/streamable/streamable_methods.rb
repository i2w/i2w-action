# frozen_string_literal: true

require_relative './dom_id'

module I2w
  class Streamable < DataObject::Mutable
    # mixin for Streamable inner classes
    module StreamableMethods
      def target_id(...) = dom_id(*target(...))

      def stream = [*stream_prefix, *stream_from]

      def content(prefix = nil) = renderer.render(formats: [:html], partial: partial(prefix), locals: locals)

      delegate :stream_prefix, :renderer, to: :streamable_class

      def streamable_class = self.class.module_parent

      private

      def dom_id(...) = DomId.call(...)
    end
  end
end
