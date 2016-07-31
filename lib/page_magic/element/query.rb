module PageMagic
  class Element
    # class Query - executes query on capybara driver
    class Query
      # Message template for execptions raised as a result of calling method_missing
      ELEMENT_NOT_FOUND_MSG = 'Unable to find %s'.freeze

      attr_reader :args, :multiple_results

      def initialize(args, multiple_results: false)
        @args = args
        @multiple_results = multiple_results
      end

      def execute(capybara_element)
        if multiple_results
          capybara_element.all(*args).tap do |result|
            raise Capybara::ElementNotFound if result.empty?
          end
        else
          [capybara_element.find(*args)]
        end
      rescue Capybara::Ambiguous => e
        raise AmbiguousQueryException, e.message
      rescue Capybara::ElementNotFound => e
        raise ElementMissingException, e.message
      end

      def ==(other)
        other.respond_to?(:args) && args == other.args
      end
    end
  end
end
