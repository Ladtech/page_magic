# frozen_string_literal: true

module PageMagic
  # class ElementContext - resolves which element definition to use when accessing the browser.
  class ElementContext
    attr_reader :page_element

    def initialize(page_element)
      @page_element = page_element
    end

    # acts as proxy to element definitions defined on @page_element
    # @return [Object] result of calling method on page_element
    # @return [Element] page element containing located browser element
    # @return [Array<Element>] array of elements if more that one result was found the browser
    def method_missing(method, *args, &block)
      return page_element.send(method, *args, &block) if page_element.methods.include?(method)

      builder = page_element.element_by_name(method, *args)

      super unless builder

      builder.build(page_element.browser_element)
    end

    def respond_to_missing?(*args)
      page_element.respond_to?(*args) || super
    end
  end
end
