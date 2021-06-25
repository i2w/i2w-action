require_relative 'streamable'
require_relative 'stream/view'

module I2w
  # provides a set of conventions for streaming models using Hotwire
  #
  # define <model>Streamable in your application to override default behaviour
  class Stream
    def self.[](*streamable, later: true, **opts)
      new Streamable.lookup(*streamable, **opts), later: later
    end

    def self.view(view, *streamable, **opts)
      View.new(view, Streamable.lookup(*streamable, **opts))
    end

    attr_reader :streamable

    def initialize(streamable, later: false)
      @later = later
      @streamable = streamable
    end

    def later? = @later

    def remove(prefix = nil) = broadcast(:remove, :target_id, prefix, content: false)

    def replace(prefix = nil, &content) = broadcast(:replace, :target_id, prefix, content: content)

    def append(prefix = nil, &content)
      remove(prefix) # TODO: review this once hotwire resolves the double append behaviour
      broadcast(:append, :parent_id, prefix, content: content)
    end

    def prepend(prefix = nil, &content)
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
      content = content.call if content.respond_to?(:call)
      opts[:content] = content || streamable.content(prefix) unless content == false

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
