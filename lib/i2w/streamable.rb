# frozen_string_literal: true

require 'i2w/data_object'

require_relative 'streamable/lookup'
require_relative 'streamable/belongs_to'
require_relative 'streamable/dom_id'

module I2w
  # Given a model or a model class, a streamable implements the interface used by Stream and Stream::View
  class Streamable
    include DataObject::Attributes
    extend BelongsTo

    class << self
      def lookup(...) = Lookup.call(...)
      alias [] lookup

      def model(&block) = self::ModelMethods.module_eval(&block)

      def model_class(&block) = self::ModelClassMethods.module_eval(&block)

      private

      def inherited(subclass)
        super
        return unless subclass.name =~ /Streamable\z/

        setup_specialized_class(subclass, 'Model')
        setup_specialized_class(subclass, 'ModelClass')
      end

      def setup_specialized_class(subclass, name)
        mod_name = "#{name}Methods"
        subclass.const_set mod_name, Module.new.include(const_get(mod_name)).extend(DataObject::DefineAttributes)
        subclass.const_set name, Class.new(subclass).include(subclass.const_get(mod_name))
      end
    end

    attr_reader :streamed, :namespace

    def initialize(streamed, namespace: nil, **attributes)
      @namespace = namespace
      @streamed = streamed
      super(**attributes)
    end

    def renderer = ActionController::Base

    def stream_prefix = [Rails.application.railtie_name]

    def stream_from = streamed

    def stream = [*stream_prefix, *stream_from]

    def target(prefix = nil) = [*prefix, streamed]

    def target_id(...) = dom_id(*target(...))

    def content(prefix = nil) = renderer.render(formats: [:html], partial: partial(prefix), locals: locals)

    def dom_id(...) = DomId.call(...)

    def streamable(*args, **opts)
      Streamable.lookup(*args, namespace: namespace, **opts)
    end

    # included into the specialized Model Streamable
    module ModelClassMethods
      def model_class = streamed

      def model_name = streamed.model_name

      def locals = { model_class: model_class, **attributes }

      def partial(template) = [model_name.collection, template].join('/')
    end

    class ModelClass < Streamable
      include ModelClassMethods
    end

    # included into the specialized Model Class Streamable
    module ModelMethods
      def model = streamed

      def model_class = streamed.class

      def model_name = streamed.model_name

      def parent_id(prefix = nil) = parent.target_id(prefix)

      def locals = { model_name.element.to_sym => model, model: model, model_class: model.class, **attributes }

      def partial(prefix = nil) = [model_name.collection, [*prefix, model_name.element].join('_')].join('/')

      def parent = streamable(model_class)
    end

    class Model < Streamable
      include ModelMethods
    end
  end
end
