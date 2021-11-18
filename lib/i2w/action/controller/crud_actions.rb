# frozen_string_literal: true

module I2w
  class Action
    module Controller
      module CrudActions
        extend ActiveSupport::Concern

        included do
          include Controller
        end

        private

        def locals = { model_class: model_class }

        def redirect_to_model_or_index(hash) = respond_to?(:show) ? redirect_to_model(hash) : redirect_to_index(hash)

        def redirect_to_model(hash) = redirect_to(url_for id: hash[:model].id)

        def redirect_to_index(_hash) = redirect_to(url_for action: :index)

        module ClassMethods
          def crud_actions(model_class = nil, repository_class: nil, input_class: nil, only: nil, except: nil)
            self.model_class = model_class unless model_class.nil?
            self.input_class = input_class unless input_class.nil?
            self.repository_class = repository_class unless repository_class.nil?

            actions = %i[index show new edit create update destroy] - [*except]
            actions = [*only] & actions if [*only].any?

            actions.each { |action| include const_get(action.to_s.classify) }
          end
        end

        module Index
          def index = index_response(action(:index).call)

          private

          def index_response(result) = render('index', locals: { **locals, **result })
        end

        module Show
          def show = show_response(action(:show).call id: params[:id])

          private

          def show_response(result) = render('show', locals: { **locals, **result })
        end

        module New
          def new = new_response(action(:new).call)

          private

          def new_response(result) = render('new', locals: { **locals, **result })
        end

        module Edit
          def edit = edit_response(action(:edit).call id: params[:id])

          private

          def edit_response(result) = render('edit', locals: { **locals, **result })
        end

        module Create
          def create = create_response(action(:create).call input: attributes)

          private

          def create_response(result)
            return new_response(result.failure) if result.failure?

            create_success(result.value)
          end

          def create_success(success)
            model = success.fetch(:model)
            flash[:notice] = "Created #{Human[model]}"

            respond_to do |format|
              format.turbo_stream { render 'create', locals: { **locals, **success } }
              format.html { redirect_to_model_or_index(success) }
            end
          end
        end

        module Update
          def update = update_response(action(:update).call id: params[:id], input: attributes)

          private

          def update_response(result)
            return edit_response(result.failure) if result.failure?

            update_success(result.value)
          end

          def update_success(success)
            model = success.fetch(:model)
            flash[:notice] = "Updated #{Human[model]}"

            respond_to do |format|
              format.turbo_stream { render 'update', locals: { **locals, **success } }
              format.html { redirect_to_model_or_index(success) }
            end
          end
        end

        module Destroy
          def destroy = destroy_response(action(:destroy).call id: params[:id])

          private

          def destroy_response(result)
            return destroy_failure(result.failure) if result.failure?

            destroy_success(result.value)
          end

          def destroy_success(success)
            model = success.fetch(:model)
            flash[:notice] = "Destroyed #{Human[model]}"

            respond_to do |format|
              format.turbo_stream { render 'destroy', locals: { **locals, **success } }
              format.html { redirect_to url_for(action: :index) }
            end
          end

          def destroy_failure(failure)
            input = failure.fetch(:input)
            flash[:alert] = "Destroy failed: #{Human[input.errors]}"

            respond_to do |format|
              format.turbo_stream { render :destroy_failure, locals: { **locals, **failure } }
              format.html { redirect_to url_for(action: :index) }
            end
          end
        end
      end
    end
  end
end
