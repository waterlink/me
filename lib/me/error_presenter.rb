require "me/errors"
require "me/registry"

module Me
  class ErrorPresenter
    def call
      yield
    rescue Errors::Base => error
      Incident[error].view
    end

    private

    class Incident < Struct.new(:error)
      def view
        error.build_view(view_factory)
      end

      private

      def view_factory
        error_view_factories.fetch(error.name, ReRaise)
      end

      def error_view_factories
        Registry.error_view_factories
      end
    end

    module ReRaise
      def self.new(error, *)
        raise error
      end
    end
  end
end
