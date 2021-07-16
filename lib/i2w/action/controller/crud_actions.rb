# frozen_string_literal: true

module I2w
  class Action
    module Controller
      module CrudActions
        extend ActiveSupport::Concern

        included do
          include Controller
        end

        module ClassMethods
          def crud_actions(model_class = nil, repository_class: nil, input_class: nil, only: nil, except: nil)
            self.model_class = model_class unless model_class.nil?
            self.input_class = input_class unless input_class.nil?
            self.repository_class = repository_class unless repository_class.nil?

            actions = %i[index show new edit create update destroy] - [*except]
            actions = [*only] - actions if only&.any?

            actions.each { |action| include const_get(action.to_s.classify) }
          end
        end

        module Index
          def index
            index_response action(:index).call
          end

          private

          def index_response(result)
            render :index, locals: { **action_locals, models: result.value }
          end
        end

        module Show
          def show
            show_response action(:show).call(params[:id])
          end

          private

          def show_response(result)
            render :show, locals: { **action_locals, model: result.value }
          end
        end

        module New
          def new
            new_response action(:new).call
          end

          private

          def new_response(result)
            render :new, locals: { **action_locals, input: result.value }
          end
        end

        module Edit
          def edit
            edit_response action(:edit).call(params[:id])
          end

          private

          def edit_response(result)
            render :edit, locals: { **action_locals, input: result.value.input, model: result.value.model }
          end
        end

        module Create
          def create
            create_response action(:create).call(action_attributes)
          end

          private

          def create_response(result)
            if result.success?
              create_success(result.value)
            else
              create_failure(result.failure)
            end
          end

          def create_success(model)
            flash[:notice] = "Created #{Human[model]}"

            respond_to do |format|
              format.turbo_stream { render :create, locals: { **action_locals, model: model } }
              format.html { redirect_to url_for(respond_to?(:show) ? { id: model.id } : { action: :index }) }
            end
          end

          def create_failure(input)
            render :new, locals: { **action_locals, input: input }
          end
        end

        module Update
          def update
            update_response action(:update).call(params[:id], action_attributes)
          end

          private

          def update_response(result)
            if result.success?
              update_success(result.value)
            else
              update_failure(result.failure)
            end
          end

          def update_success(model)
            flash[:notice] = "Updated #{Human[model]}"

            respond_to do |format|
              format.turbo_stream { render :update, locals: { **action_locals, model: model } }
              format.html { redirect_to url_for(respond_to?(:show) ? { id: model.id } : { action: :index }) }
            end
          end

          def update_failure(failure)
            render :edit, locals: { **action_locals, input: failure.input, model: failure.model }
          end
        end

        module Destroy
          def destroy
            destroy_response action(:destroy).call(params[:id])
          end

          private

          def destroy_response(result)
            if result.success?
              destroy_success(result.value)
            else
              destroy_failure(result.failure)
            end
          end

          def destroy_success(model)
            flash[:notice] = "Destroyed #{Human[model]}"

            respond_to do |format|
              format.turbo_stream { render :destroy, locals: { **action_locals, model: model } }
              format.html { redirect_to url_for(action: :index) }
            end
          end

          def destroy_failure(failure)
            flash[:alert] = "Destroy failed: #{Human[failure.errors]}"

            respond_to do |format|
              format.turbo_stream { render :destroy_failure, locals: { **action_locals, model: failure.model } }
              format.html { redirect_to url_for(action: :index) }
            end
          end
        end
      end
    end
  end
end
