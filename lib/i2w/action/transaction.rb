module I2w
  class Action
    # include this to have the #call method wrapped in Action#transaction, also applies to all descendents
    module Transaction
      extend ActiveSupport::Concern

      included do
        prepend Methods

        def self.inherited(subclass)
          super
          subclass.prepend Methods
        end
      end

      module Methods
        def call(...)
          transaction { super }
        end
      end
    end
  end
end
