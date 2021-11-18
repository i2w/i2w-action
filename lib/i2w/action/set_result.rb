module I2w
  class Action
    # include to have #call create an open_result and pass it to #set_open_result, and return the result
    # You will perform the logic of the action in #set_result, and it works like 'do' notation, the first
    # failure will exit early
    #
    # If you want to process some arguments, and setup the result accordingly, perhaps in a superclass or mixin,
    # then use #process_args_before_set_result, which yields the unprocessed arguments
    module SetResult
      def call(*args)
        open_result do |result|
          process_args_before_set_result(result, *args) do |*unprocessed_args|
            set_result(result, *unprocessed_args)
          end
        end
      end

      private

      # process any arguments, perhaps adding to the result.  Yield any unprocessed args
      def process_args_before_set_result(_result, *args) = yield(*args)

      def set_result(result, *args)
        raise ArgumentError, "unprocessed arguments: #{args}" if args.any?
      end
    end
  end
end