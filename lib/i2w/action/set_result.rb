module I2w
  class Action
    # include to have #call create an open_result and pass it to #set_result, and return the result
    # You will perform the logic of the action in #set_result, and it works like 'do' notation, the first
    # failure will exit early
    #
    # If you want to process some arguments, and setup the result accordingly, perhaps in a superclass or mixin,
    # then use #before_set_result, which must return any unprocessed kwargs.
    module SetResult
      def call(**kwargs)
        open_result do |result|
          unprocessed_kwargs = before_set_result(result, **kwargs)
          set_result(result, **unprocessed_kwargs)
        end
      end

      private

      # Process any arguments, perhaps mutating the result, before #set_result is called
      # You must return any unprocessed kwargs, these will be passed to #set_result
      def before_set_result(_result, **kwargs) = kwargs

      def set_result(_result, **kwargs)
        raise ArgumentError, "unprocessed arguments: #{kwargs}" if kwargs.any?
      end
    end
  end
end