# frozen_string_literal: true

module I2w
  class Action
    # example implementations of standard CRUD actions
    #
    # You can help yourself to these implementations as follows:
    #
    # In app/actions/create_action.rb
    #
    #     class CreateAction < ApplicationAction
    #       include I2w::Action::Actions::Create
    #     end
    #
    # Or, just use them as a guide.
    module Actions
      # Default implementation of the index action
      module Index
        def call
          repo.all
        end
      end

      # Default implementation of the new action
      module Show
        def call(id)
          repo.find(id)
        end
      end

      # Default implementation of the new action
      module New
        def call
          Result.success input_class.new
        end
      end

      # Default implementation of the edit action
      module Edit
        def call(id)
          repo.find(id).and_then { |model| input_class.from(model) }
        end
      end

      # default implementation of the create action
      module Create
        def call(input)
          validate(input).and_then { |valid_input| repo.create(valid_input) }
        end
      end

      # Default implementation of the update action
      module Update
        def call(id, input)
          validate(input).and_then { |valid_input| repo.update(id, valid_input) }
        end
      end

      # Default implementation of the destroy action
      module Destroy
        def call(id)
          repo.destroy(id)
        end
      end
    end
  end
end
