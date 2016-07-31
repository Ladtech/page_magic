module PageMagic
  # class ElementContext - resolves which element definition to use when accessing the browser.
  class ElementContext
    attr_reader :page_element

    def initialize(page_element)
      @page_element = page_element
    end

    # acts as proxy to element defintions defined on @page_element
    # @return [Object] result of callng method on page_element
    # @return [Element] animated page element containing located browser element
    # @return [Array<Element>] array of elements if more that one result was found the browser
    def method_missing(method, *args, &block)
      return page_element.send(method, *args, &block) if page_element.methods.include?(method)

      builder = page_element.element_by_name(method, *args)

      super unless builder

      prefecteched_element = builder.element
      return builder.build(prefecteched_element) if prefecteched_element

      elements = find(builder)
      elements.size == 1 ? elements.first : elements
    end

    def respond_to?(*args)
      page_element.respond_to?(*args) || super
    end

    private

    def find(builder)
      result = builder.build_query.execute(page_element.browser_element)
      result.to_a.collect { |e| builder.build(e) }
    end
  end
end
