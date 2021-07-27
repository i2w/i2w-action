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
        def call
          hash_result { |h| h[:models] = repo.all }
        end
      end

      # Default implementation of the new action, returns HashResult with :model
      module Show
        def call(id)
          hash_result { |h| h[:model] = repo.find id: id }
        end
      end

      # Default implementation of the new action returns HashResult with :input
      module New
        def call
          hash_result { |h| h[:input] = input_class.new }
        end
      end

      # Default implementation of the edit action returns HashResult with :model, :input
      module Edit
        def call(id)
          hash_result do |h|
            h[:model] = repo.find(id: id)
            h[:input] = input_class.new(h[:model])
          end
        end
      end

      # default implementation of the create action,
      # returns HashResult with :model on success, :model and :input on failure
      module Create
        def call(attributes)
          hash_result do |h|
            h[:input] = validate(attributes)
            h[:model, :input] = repo.create input: h[:input]
          end
        end
      end

      # Default implementation of the update action,
      # returns HashResult with :model on success, :model and :input on failure
      module Update
        def call(id, attributes)
          hash_result do |h|
            h[:model] = repo.find id: id
            h[:input] = validate(attributes)
            h[:model, :input] = repo.update id: id, input: h[:input]
          end
        end
      end

      # Default implementation of the destroy action,
      # returns HashResult with :model on success, :input on failure
      module Destroy
        def call(id)
          hash_result { |h| h[:model, :input] = repo.destroy id: id }
        end
      end
    end
  end
end
