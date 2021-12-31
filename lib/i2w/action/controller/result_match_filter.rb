# frozen_string_literal: true

module I2w
  class Action
    module Controller
      class ResultMatchFilter
        def self.around(controller)
          yield

        rescue Result::MatchNotFoundError => e

          controller.class.result_match_handlers.reverse_each do |handler|
            return Result.match(e.result) { |on| controller.instance_exec(on, &handler) }
          rescue Result::MatchNotFoundError
          end

          raise e
        end
      end
    end
  end
end