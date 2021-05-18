module I2w
  class Streamable
    module StreamableMethods
      def target_id(...) = dom_id(*target(...))

      def stream = [*stream_prefix, *stream_from]

      def content(prefix = nil) = renderer.render(formats: [:html], partial: partial(prefix), locals: locals)

      private

      def dom_id(...) = DomId.call(...)
    end
  end
end
