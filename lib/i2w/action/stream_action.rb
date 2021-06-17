# frozen_string_literal: true

module I2w
  class Action
    # prepend these in action classes to stream succesful results
    module StreamAction
      # append streamable on success
      module Append
        def call(...) = super.and_tap { Stream[_1].append }
      end

      # prepend streamable on success
      module Prepend
        def call(...) = super.and_tap { Stream[_1].prepend }
      end

      # remove streamable on success
      module Remove
        def call(...) = super.and_tap { Stream[_1].remove }
      end

      # replace streamable on success
      module Replace
        def call(...) = super.and_tap { Stream[_1].replace }
      end
    end
  end
end
