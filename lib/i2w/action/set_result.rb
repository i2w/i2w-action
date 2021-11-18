module I2w
  class Action
    # include to have #call create an open_result and pass it to #set_open_result, and return the result
    # You will perform the logic of the action in #set_result, and it works like 'do' notation, the first
    # failure will exit early
    #
    # If you want to process some arguments, and setup the result accordingly, perhaps in a superclass or mixin,
    # then use #before_set_result, which is allowed to mutate the arguments array
    module SetResult
      def call(*args)
        open_result do |result|
          before_set_result(result, args)
          set_result(result, *args)
        end
      end

      private

      # process any arguments, perhaps adding to the result. You can mutate the arguments (and the result)
      # before they are passed to #set_result
      def before_set_result(_result, _args); end

      def set_result(_result, *args)
        raise ArgumentError, "unprocessed arguments: #{args}" if args.any?
      end
    end
  end
end