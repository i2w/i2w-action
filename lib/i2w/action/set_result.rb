module I2w
  class Action
    # include to have #call create an open_result and pass it to #set_result, and return the result
    # You will perform the logic of the action in #set_result, and it works like 'do' notation, the first
    # failure will exit early
    #
    # If you want to process some arguments, and setup the result accordingly, perhaps in a superclass or mixin,
    # then use #before_set_result, which must return any unprocessed kwargs.
    module SetResult
      def call(*args)
        open_result do |result|
          unprocessed_args = before_set_result(result, *args)
          set_result(result, *unprocessed_args)
        end
      end

      private

      # Process any arguments, perhaps mutating the result, before #set_result is called
      # You must return any unprocessed args, these will be passed to #set_result
      def before_set_result(_result, *args) = args

      def set_result(_result, *args)
        raise ArgumentError, "unprocessed arguments: #{args}" if args.any?
      end
    end
  end
end