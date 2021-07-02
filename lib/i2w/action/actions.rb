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
          repo.find id: id
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
          repo.find(id: id).and_then { |model| input_class.with_model(model) }
        end
      end

      # default implementation of the create action
      module Create
        def call(attributes)
          validate(attributes).and_then { |valid| repo.create input: valid }
        end
      end

      # Default implementation of the update action, failure includes the model and input
      module Update
        def call(id, attributes)
          validate(attributes, id).and_then { |valid| repo.update id: id, input: valid }
        end
      end

      # Default implementation of the destroy action
      module Destroy
        def call(id)
          repo.destroy id: id
        end
      end
    end
  end
end
