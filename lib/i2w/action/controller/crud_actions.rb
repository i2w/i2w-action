# frozen_string_literal: true

module I2w
  class Action
    module Controller
      module CrudActions
        extend ActiveSupport::Concern

        module ClassMethods
          def crud_actions(model_name = nil, repo_class: nil, input_class: nil, only: [], except: [])
            include DefaultAction

            self.repo_class = repo_class unless repo_class.nil?
            self.model_name = model_name unless model_name.nil?
            self.input_class = input_class unless input_class.nil?

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
            input = default_input
            result = default_action(input)

            if result.success?
              create_success(result.value)
            else
              create_failure(input, result.errors)
            end
          end

          private

          def create_success(model)
            redirect_to (respond_to?(:show) ? model : { action: :index }), notice: "Created #{Human[model]}"
          end

          def create_failure(input, errors)
            input.errors = errors
            render :new, assigns: { input: input }
          end
        end

        module Update
          def update
            input = default_input
            result = default_action(params[:id], input)

            if result.success?
              update_success(result.value)
            else
              update_failure(input, result.errors)
            end
          end

          private

          def update_success(model)
            redirect_to (respond_to?(:show) ? model : { action: :index }), notice: "Updated #{Human[model]}"
          end

          def update_failure(input, errors)
            input.errors = errors
            render :edit, assigns: { input: input }
          end
        end

        module Destroy
          def destroy
            result = default_action(params[:id])

            if result.success?
              destroy_success(result.value)
            else
              destroy_failure(errors)
            end
          end

          private

          def destroy_success(model)
            redirect_to url_for(action: :index), notice: "Destroyed #{Human[model]}"
          end

          def destroy_failure(errors)
            redirect_to url_for(action: :index), notice: "Destroy failed: #{Human[errors]}"
          end
        end
      end
    end
  end
end
