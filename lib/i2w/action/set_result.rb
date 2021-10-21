module I2w
  class Action
    # include to have #call create an open_result and pass it to #set_open_result, and return the result
    # You will perform the logic of the action in #set_open_result, and it works like 'do' notation, the first
    # failure will exit early
    module SetResult
      def call(...)
        Result.open_result { set_result(_1, ...) }
      end

      private

      def set_result(result, ...)
        raise NotImplementedError, 'implement #set_result(result, ...)'
      end
    end
  end
end