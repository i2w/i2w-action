# frozen_string_literal: true

module I2w
  class Action
    module Controller
      module CrudActions
        extend ActiveSupport::Concern

        included do
          include Controller

          dependency :model_class, class_lookup { _1.sub(/Controller\z/, '').singularize }
          dependency :repo,        class_lookup { _1.sub(/Controller\z/, '').singularize + 'Repo' }

          provide_action_dependency :input_class
          provide_action_dependency :repo
        end

        private

        def redirect_to_model_or_index(hashy)
          respond_to?(:show) ? redirect_to_model(hashy) : redirect_to_index(hashy)
        end

        def redirect_to_model(hashy)
          redirect_to url_for id: hashy.fetch(:model).id
        end

        def redirect_to_index(_hashy)
          redirect_to url_for action: :index
        end

        def locals
          { model_class: model_class }
        end

        module ClassMethods
          def crud_actions(model_class = nil, repo: nil, input_class: nil, only: nil, except: nil)
            dependency(:model_class, model_class) unless model_class.nil?
            dependency(:input_class, input_class) unless input_class.nil?
            dependency(:repo, repo)               unless repo.nil?

            actions = %i[index show new edit create update destroy] - [*except]
            actions = [*only] & actions if [*only].any?

            actions.each { |action| include const_get(action.to_s.classify) }
          end
        end

        module Index
          def index
            render_action :index
          end
        end

        module Show
          def show
            render_action :show, **parameters(:id)
          end
        end

        module New
          def new
            render_action :new
          end
        end

        module Edit
          def edit
            render_action :edit, **parameters(:id)
          end
        end

        module Create
          def create
            on_create_result action(:create).call(input: attributes)
          end

          private

          def on_create_result(result)
            on_result result do |on|
              on.success { create_success _1 }
              on.failure { render_template :new, _1 }
            end
          end

          def create_success(success)
            model = success.fetch(:model)
            flash[:notice] = "Created #{Human[model]}"

            respond_to do |f|
              f.turbo_stream { render_template :create, success }
              f.html         { redirect_to_model_or_index(success) }
            end
          end
        end

        module Update
          def update
            on_update_result action(:update).call(input: attributes, **parameters(:id))
          end

          private

          def on_update_result(result)
            on_result result do |on|
              on.success { update_success _1 }
              on.failure { render_template :edit, _1 }
            end
          end

          def update_success(success)
            model = success.fetch(:model)
            flash[:notice] = "Updated #{Human[model]}"

            respond_to do |f|
              f.turbo_stream { render_template :update, success }
              f.html         { redirect_to_model_or_index success }
            end
          end
        end

        module Destroy
          def destroy
            on_destroy_result action(:destroy).call(**parameters(:id))
          end

          private

          def on_destroy_result(result)
            on_result do |on|
              on.success { destroy_success _1 }
              on.failure { destroy_failure _1 }
            end
          end

          def destroy_success(success)
            model = success.fetch(:model)
            flash[:notice] = "Destroyed #{Human[model]}"

            respond_to do |f|
              f.turbo_stream { render_template :destroy, success }
              f.html         { redirect_to url_for(action: :index) }
            end
          end

          def destroy_failure(failure)
            input = failure.fetch(:input)
            flash[:alert] = "Destroy failed: #{Human[input.errors]}"

            respond_to do |f|
              f.turbo_stream { render_template :destroy_failure, failure }
              f.html         { redirect_to url_for(action: :index) }
            end
          end
        end
      end
    end
  end
end
