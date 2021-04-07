# frozen_string_literal: true

module I2w
  module Action
    # Default implementation of the edit action
    module Edit
      def call(id)
        repo.find(id).and_then { |model| input_class.from(model) }
      end
    end
  end
end
