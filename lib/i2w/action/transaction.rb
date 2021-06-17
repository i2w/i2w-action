module I2w
  class Action
    # include this to have the #call method wrapped in Action#transaction
    module Transaction
      def call(...)
        transaction { super }
      end
    end
  end
end
