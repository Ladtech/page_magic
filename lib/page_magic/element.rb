module PageMagic
  module MethodObserver
    def singleton_method_added(arg)
      @singleton_methods_added = true unless arg == :singleton_method_added
    end

    def singleton_methods_added?
      @singleton_methods_added == true
    end
  end

  class Element
    attr_reader :type, :name, :selector, :browser_element

    include Elements

    class << self
      def inherited(clazz)
        clazz.extend(Elements)

        def clazz.selector(selector = nil)
          return @selector unless selector
          @selector = selector
        end
      end
    end

    def initialize(name, parent_page_element, options, &block)
      options = { type: :element, selector: {}, browser_element: nil }.merge(options)
      @browser_element = options[:browser_element]
      @selector = options[:selector]

      @before_hook = proc {}
      @after_hook = proc {}
      @parent_page_element = parent_page_element
      @type = options[:type]
      @name = name.to_s.downcase.to_sym

      extend MethodObserver
      expand &block if block
    end

    def expand(*args, &block)
      instance_exec *args, &block
    end

    def selector(selector = nil)
      return @selector unless selector
      @selector = selector
    end

    def section?
      !element_definitions.empty? || singleton_methods_added?
    end

    def session
      @parent_page_element.session
    end

    def before(&block)
      return @before_hook unless block
      @before_hook = block
    end

    def after(&block)
      return @after_hook unless block
      @after_hook = block
    end

    def method_missing(method, *args)
      element_context(args).send(method, args.first)
    rescue ElementMissingException
      begin
        @browser_element.send(method, *args)
      rescue
        super
      end
    end

    def respond_to?(*args)
      super || element_context.respond_to?(*args) || @browser_element.respond_to?(*args)
    end

    def browser_element(*_args)
      return @browser_element if @browser_element
      fail UndefinedSelectorException, 'Pass a selector/define one on the class' if @selector.empty?
      if @selector
        selector_copy = @selector.dup
        method = selector.keys.first
        selector = selector_copy.delete(method)
        options = selector_copy

        finder_method, selector_type, selector_arg = case method
                                                     when :id
                                                       [:find, "##{selector}"]
                                                     when :xpath
                                                       [:find, :xpath, selector]
                                                     when :name
                                                       [:find, "*[name='#{selector}']"]
                                                     when :css
                                                       [:find, :css, selector]
                                                     when :label
                                                       [:find_field, selector]
                                                     when :text
                                                       if @type == :link
                                                         [:find_link, selector]
                                                       elsif @type == :button
                                                         [:find_button, selector]
                                                       else
                                                         fail UnsupportedSelectorException
                                                       end

                                                     else
                                                       fail UnsupportedSelectorException
                                                     end

        finder_args = [selector_type, selector_arg].compact
        finder_args << options unless options.empty?
        @browser_element = @parent_page_element.browser_element.send(finder_method, *finder_args)
      end
      @browser_element
    end

    private

    def element_context(*args)
      ElementContext.new(self, @browser_element, self, *args)
    end
  end
end
