require_relative 'streamable'
require_relative 'stream/view'

module I2w
  class Stream
    def self.[](*streamable, later: false, **opts)
      new Streamable.lookup(*streamable, **opts), later: later
    end

    attr_reader :streamable

    def initialize(streamable, later: false)
      @later = later
      @streamable = streamable
    end

    def later? = @later

    def remove(prefix = nil) = broadcast(:remove, :target_id, prefix, content: false)

    def replace(prefix = nil, content: true) = broadcast(:replace, :target_id, prefix, content: content)

    def append(prefix = nil, content: true)
      remove(prefix) # TODO: review this once hotwire resolves the double append behaviour
      broadcast(:append, :parent_id, prefix, content: content)
    end

    def prepend(prefix = nil, content: true)
      remove(prefix) # TODO: review this once hotwire resolves the double append behaviour
      broadcast(:prepend, :parent_id, prefix, content: content)
    end

    def parent
      self.class.new(streamable.parent, later: later?)
    end

    private

    def broadcast(action, id, prefix = nil, content:)
      stream = streamable.stream
      opts = { action: action, target: streamable.send(id, prefix) }
      opts[:content] = streamable.content(prefix) if content

      later? ? broadcast_later(stream, opts) : broadcast_now(stream, opts)
    end

    def broadcast_later(stream, opts)
      Turbo::StreamsChannel.broadcast_action_later_to(*stream, **opts)
    end

    def broadcast_now(stream, opts)
      Turbo::StreamsChannel.broadcast_action_to(*stream, **opts)
    end
  end
end
