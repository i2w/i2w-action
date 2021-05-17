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
          repo.find(id: id).and_then { |model| input_class.new(model) }
          end
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
        # include Result::Call
        #
        # def call(id, attributes)
        #   valid = value validate(attributes)
        #   repo.update id: id, input: valid
        # end

        def call(id, attributes)
          result = validate(attributes).and_then { |valid| repo.update id: id, input: valid }
        end
      end

      # Implementation of patch, which is like update, but has partial input which is patched onto the existing
      # before validation
      module Patch
        # extend ActiveSupport::Concern
        # 
        # included do
        #   include Result::Call
        #   include Action::Transaction
        # end
        #
        # def call(id, patch)
        #   model = value repo.find(id)
        #   value validate(**model, **patch)
        #   repo.update id: id, input: patch
        # end
        def call(id, patch)
          transaction do
            Result[id].and_then { |id| repo.find id: id }
                      .and_then { |model| validate(**model, **patch) }
                      .and_then { |valid| repo.update id: id, input: valid }
          end
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
