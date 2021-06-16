module I2w
  class Stream
    class View
      attr_reader :view, :streamable

      def initialize(view, streamable)
        @view = view
        @streamable = streamable
      end

      def frame(prefix = nil, **opts, &block) = render_frame(:target_id, prefix, **opts, &block)

      def stream = view.turbo_stream_from(streamable.stream)

      def remove(prefix = nil) = render_stream(:remove, :target_id, prefix, content: false)

      def replace(prefix = nil, &content) = render_stream(:replace, :target_id, prefix, content: content)

      def append(prefix = nil, &content)
        # TODO: review this once hotwire resolves the double append behaviour
        remove(prefix) + render_stream(:append, :parent_id, prefix, content: content)
      end

      def prepend(prefix = nil, &content)
        # TODO: review this once hotwire resolves the double append behaviour
        remove(prefix) + render_stream(:prepend, :parent_id, prefix, content: content)
      end

      def parent
        self.class.new(view, streamable.parent)
      end

      private

      def render_stream(action, id, prefix, content:)
        content ||= default_content(prefix) unless content == false
        view.turbo_stream.send(action, streamable.send(id, prefix), &content.presence)
      end

      def render_frame(id, prefix, **opts, &block)
        view.turbo_frame_tag(streamable.send(id, prefix), **opts, &block)
      end

      def default_content(prefix)
        proc { view.render streamable.partial(prefix), streamable.locals }
      end
    end
  end
end
