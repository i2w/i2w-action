# frozen_string_literal: true

module I2w
  class Action
    module Controller
      module CrudActions
        extend ActiveSupport::Concern

        module ClassMethods
          def crud_actions(model_name = nil, repo: nil, input_class: nil, only: [], except: [])
            include DefaultAction

            self.model_name = model_name unless model_name.nil?
            self.input_class = input_class unless input_class.nil?
            self.repo = repo unless repo.nil?

            actions = %i[index show new edit create update destroy] - except
            actions = only - actions if only.any?

            actions.each { |action| include const_get(action.to_s.classify) }
          end
        end

        module Index
          def index
            @models = default_action.value
          end
        end

        module Show
          def show
            @model = default_action(params[:id]).value
          end
        end

        module New
          def new
            @input = default_action.value
          end
        end

        module Edit
          def edit
            @input = default_action(params[:id]).value
          end
        end

        module Create
          def create
            case default_action(input = default_input)
            in :success, model
              create_success(model)
            in :failure, failure, errors
              create_failure(input, failure, errors)
            end
          end

          private

          def create_success(model)
            redirect_to (respond_to?(:show) ? model : { action: :index }), notice: "Created #{Human[model]}"
          end

          def create_failure(input, _failure, errors)
            render :new, assigns: { errors: errors, input: input }
          end
        end

        module Update
          def update
            case default_action(params[:id], input = default_input)
            in :success, model
              update_success(model)
            in :failure, failure, errors
              update_failure(input, failure, errors)
            end
          end

          private

          def update_success(model)
            redirect_to (respond_to?(:show) ? model : { action: :index }), notice: "Updated #{Human[model]}"
          end

          def update_failure(input, _failure, errors)
            render :edit, assigns: { errors: errors, input: input }
          end
        end

        module Destroy
          def destroy
            case default_action(params[:id])
            in :success, model
              destroy_success(model)
            in :failure, failure, errors
              destroy_failure(failure, errors)
            end
          end

          private

          def destroy_success(model)
            redirect_to action: :index, notice: "Destroyed #{Human[model]}"
          end

          def destroy_failure(_failure, errors)
            redirect_to action: :index, notice: "Destroy failed: #{Human[errors]}"
          end
        end
      end
    end
  end
end
