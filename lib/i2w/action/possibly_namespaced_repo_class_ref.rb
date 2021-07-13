# frozen_string_literal: true

module I2w
  class Action
    # Actions are often namespaced, so we attempt to also load repo classes outside of the namespace
    class PossiblyNamespacedRepoClassRef < Repo::Class::Ref
      def try_constantize(class_name)
        parts = class_name.split('::')
        candidates = parts.length.times.map { parts[_1..].join('::').to_s }
        candidates.each do |candidate|
          return candidate.constantize
        rescue NameError
          nil
        end
      end
    end
  end
end
