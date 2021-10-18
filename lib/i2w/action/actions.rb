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
      # Default implementation of the index action, returns HashResult with :model
      module Index
        def set_result(result)
          result.models = repo.all
        end
      end

      # Default implementation of the new action, returns HashResult with :model
      module Show
        def set_result(result, id)
          result.model = repo.find(id: id)
        end
      end

      # Default implementation of the new action returns HashResult with :input
      module New
        def set_result
          result.input = input_class.new
        end
      end

      # Default implementation of the edit action returns HashResult with :model, :input
      module Edit
        def set_result(result, id)
          result.model = repo.find(id: id)
          result.input = input_class.new(result.model)
        end
      end

      # default implementation of the create action,
      # returns OpenResult with :model on success, :model and :input on failure
      module Create
        def set_result(result, attributes)
          result.input = validate(attributes)
          result[:model, :input] = repo.create input: result.input
        end
      end

      # Default implementation of the update action,
      # returns OpenResult with :model on success, :model and :input on failure
      module Update
        def set_result(result, id, attributes)
          result.model = repo.find id: id
          result.input = validate(attributes)
          result[:model, :input] = repo.update id: id, input: result.input
        end
      end

      # Default implementation of the destroy action,
      # returns HashResult with :model on success, :input on failure
      module Destroy
        def set_result(result, id)
          result[:model, :input] = repo.destroy id: id
        end
      end
    end
  end
end
