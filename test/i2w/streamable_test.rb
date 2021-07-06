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
      model_class do
        attribute :room_id

        def stream_from = Room

        def target(prefix = nil) = [*prefix, Room.from(id: room_id), Message]
      end

      model do
        def parent = streamable(model_class, room_id: model.room_id)
      end
    end

    class EveryMessageStreamable < Streamable
    end

    module Namespace
      class MessageStreamable < StreamableTest::MessageStreamable
      end
    end

    test 'Streamable[...] returns corresponding Streamable class' do
      room = Room.from(name: 'lobby', id: 1)
      msg1 = Message.from(room_id: room.id, message: 'greetings!', id: 1)

      assert_equal Streamable::Model, Streamable[room].class
      assert_equal Streamable::ModelClass, Streamable[Room].class

      assert_equal MessageStreamable::Model, Streamable[msg1].class
      assert_equal MessageStreamable::ModelClass, Streamable[msg1].parent.class
      assert_equal MessageStreamable::ModelClass, Streamable[Message, room_id: 1].class

      assert_equal EveryMessageStreamable::ModelClass, Streamable[:every, Message].class
      assert_equal EveryMessageStreamable::Model, Streamable[:every, msg1].class
    end

    test 'Streamable[namespace, ...] returns namespaced Streamable class if available' do
      room = Room.from(name: 'lobby', id: 1)
      msg1 = Message.from(room_id: room.id, message: 'greetings!', id: 1)

      assert_equal Namespace::MessageStreamable::Model, Streamable[msg1, namespace: Namespace].class
      assert_equal Namespace::MessageStreamable::ModelClass, Streamable[Message, room_id: 1, namespace: Namespace].class
      assert_equal Namespace::MessageStreamable::ModelClass, Streamable[msg1, namespace: Namespace].parent.class
      assert_equal EveryMessageStreamable::Model, Streamable[:every, msg1, namespace: Namespace].class
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
