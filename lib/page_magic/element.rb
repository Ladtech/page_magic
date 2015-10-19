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
    EVENT_TYPES = [:set, :select, :select_option, :unselect_option, :click]
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
      options = {type: :element, selector: {}, browser_element: nil}.merge(options)
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

    def method_missing method, *args, &block
      begin
        ElementContext.new(self, browser_element, self, *args).send(method, args.first, &block)
      rescue ElementMissingException
        if browser_element.respond_to?(method)
          browser_element.send(method, *args, &block)
        elsif @parent_page_element.respond_to?(method)
          @parent_page_element.send(method, *args, &block)
        else
          super
        end
      end
    end

    def respond_to?(*args)
      super || element_context.respond_to?(*args) || browser_element.respond_to?(*args)
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
        @browser_element = @parent_page_element.browser_element.send(finder_method, *finder_args).tap do |browser_element|
          EVENT_TYPES.each do |action_method|
            apply_hooks(page_element: browser_element,
                        capybara_method: action_method,
                        before_hook: before,
                        after_hook: after)
          end
        end

      end
    end

    def apply_hooks(options)
      _self = self
      page_element = options[:page_element]
      capybara_method = options[:capybara_method]
      if page_element.respond_to?(capybara_method)
        original_method = page_element.method(capybara_method)

        page_element.define_singleton_method capybara_method do |*arguments, &block|
          _self.call_hook &options[:before_hook]
          original_method.call *arguments, &block
          _self.call_hook &options[:after_hook]
        end
      end
    end

    def call_hook(&block)
      @executing_hooks = true
      result = instance_exec @browser, &block
      @executing_hooks = false
      result
    end

    private

    def element_context(*args)
      ElementContext.new(self, @browser_element, self, *args)
    end
  end
end
