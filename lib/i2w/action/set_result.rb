module I2w
  class Action
    # include to have #call create an open_result and pass it to #set_open_result, and return the result
    # You will perform the logic of the action in #set_result, and it works like 'do' notation, the first
    # failure will exit early
    #
    # If you want to process some arguments, and setup the result accordingly, perhaps in a superclass or mixin,
    # then use #before_set_result, which is allowed to mutate the arguments array
    module SetResult
      def call(*args, **kwargs)
        open_result do |result|
          unprocessed_kwargs = before_set_result(result, kwargs)
          unprocessed_kwargs = kwargs unless unprocessed_kwargs.is_a?(Hash)
          set_result(result, *args, **unprocessed_kwargs)
        end
      end

      private

      # process any arguments, perhaps adding to the result. You can mutate the kwargs (and the result)
      # before they are passed to #set_result, or
      # if you don't want to mutate kwargs, you can return the unprocessed kwargs hash
      def before_set_result(_result, _kwargs); end

      def set_result(_result, **kwargs)
        raise ArgumentError, "unprocessed arguments: #{kwargs}" if kwargs.any?
      end
    end
  end
end