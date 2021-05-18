require 'test_helper'

module I2w
  class StreamableTest < ActiveSupport::TestCase
    class Room < Model::Persisted
      attribute :name
    end

    class Message < Model::Persisted
      attribute :room_id
      attribute :message
    end

    class MessageStreamable < Streamable
      class Parent < Streamable::Parent
        attr_reader :room

        def initialize(model_class, room_id:)
          @room = Room.from(id: room_id)
          super(model_class)
        end

        def stream_from = Room

        def target(prefix = nil) = [*prefix, room, Message]
      end

      def new_parent
        Parent.new(model.class, room_id: model.room_id)
      end
    end

    class EveryMessageStreamable < Streamable
    end

    test 'Streamable[...] returns corresponding Streamable class' do
      room = Room.from(name: 'lobby', id: 1)
      msg1 = Message.from(room_id: room.id, message: 'greetings!', id: 1)

      assert_equal Streamable, Streamable[room].class
      assert_equal Streamable::Parent, Streamable[Room].class

      assert_equal MessageStreamable, Streamable[msg1].class
      assert_equal MessageStreamable::Parent, Streamable[msg1].parent.class
      assert_equal MessageStreamable::Parent, Streamable[Message, room_id: 1].class

      assert_equal EveryMessageStreamable, Streamable[:every, msg1].class
      assert_equal Streamable::Parent, Streamable[:every, Message].class
    end

    test 'Streamable target_id and parent_id methods' do
      streamable = Streamable[Room.from(name: 'lobby', id: 1)]

      assert_equal 'i2w_streamable_test_room_1', streamable.target_id
      assert_equal 'edit_i2w_streamable_test_room_1', streamable.target_id(:edit)
      assert_equal 'i2w_streamable_test_rooms', streamable.parent_id
      assert_equal 'new_i2w_streamable_test_room', streamable.parent_id(:new)

      msg_streamable = Streamable[Message.from(room_id: 1, message: 'greetings!', id: 2)]

      assert_equal 'i2w_streamable_test_message_2', msg_streamable.target_id
      assert_equal 'edit_i2w_streamable_test_message_2', msg_streamable.target_id(:edit)
      assert_equal 'i2w_streamable_test_room_1_i2w_streamable_test_messages', msg_streamable.parent_id
      assert_equal 'new_i2w_streamable_test_room_1_i2w_streamable_test_message', msg_streamable.parent_id(:new)
    end
  end
end
