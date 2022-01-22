module I2w
  class Action
    # include to have #call create an open_result and pass it to #set_result, and return the result
    # You will perform the logic of the action in #set_result, and it works like 'do' notation, the first
    # failure will exit early
    module SetResult
      def call(...)
        open_result do |result|
          set_result(result, ...)
        end
      end

      def set_result(result) = result
    end
  end
end