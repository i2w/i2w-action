module I2w
  class Action
    # include to have #call create an open_result and pass it to #set_result, and return the result
    # You will perform the logic of the action in #set_result, and it works like 'do' notation, the first
    # failure will exit early
    #
    # If you want to pre-process some arguments, and setup the result accordingly, perhaps in a superclass or mixin,
    # then use #before_set_result, which must return any unprocessed args, and kwargs in an array
    module SetResult
      def call(*args, **kwargs)
        open_result do |result|
          unprocessed_args, unprocessed_kwargs = before_set_result(result, *args, **kwargs)
          set_result(result, *unprocessed_args, **unprocessed_kwargs)
        end
      end

      private

      # Process any arguments, perhaps mutating the result, before #set_result is called
      # You must return an 2 element array of unprocessed args (Array), and unprocessed keyword args (Hash)
      def before_set_result(_result, *args, **kwargs) = [args, kwargs]

      def set_result(_result, *args, **kwargs)
        raise ArgumentError, "unprocessed arguments: #{args} #{kwargs}" if args.any? || kwargs.any?
      end
    end
  end
end