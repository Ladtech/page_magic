require 'forwardable'
require 'page_magic/element/selector_methods'
require 'page_magic/element/locators'
require 'page_magic/element/selector'
require 'page_magic/element/query'
module PageMagic
  # class Element - represents an element in a html page.
  class Element
    EVENT_TYPES = [:set, :select, :select_option, :unselect_option, :click].freeze
    DEFAULT_HOOK = proc {}.freeze

    include SelectorMethods, Watchers, SessionMethods, WaitMethods, Locators
    extend Elements, SelectorMethods, Forwardable

    attr_reader :type, :name, :parent_element, :browser_element, :before_events, :after_events

    class << self
      # @!method after_events
      # If a block is passed in, it adds it to be run after an event is triggered on an element.
      # See {EVENT_TYPES} for the
      # @return [Array] all registered blocks

      # @!method before_events
      # If a block is passed in, it adds it to be run before an event is triggered on an element.
      # @see .after_events
      %i(after_events before_events).each do |method|
        define_method method do |&block|
          instance_variable_name = "@#{method}".to_sym
          instance_variable_value = instance_variable_get(instance_variable_name) || [DEFAULT_HOOK]
          instance_variable_value << block if block
          instance_variable_set(instance_variable_name, instance_variable_value)
        end
      end

      # Get/Sets the parent element desribed by this class
      # @param [Element] page_element parent page element
      # @return [Element]
      def parent_element(page_element = nil)
        return @parent_page_element unless page_element
        @parent_page_element = page_element
      end

      # called when class inherits this one
      # @param [Class] clazz inheriting class
      def inherited(clazz)
        super
        clazz.before_events.replace(before_events)
        clazz.after_events.replace(after_events)
      end

      # Defines watchers to be used by instances
      # @see Watchers#watch
      def watch(name, method = nil, &block)
        before_events { watch(name, method, &block) }
      end

      def ==(other)
        other <= PageMagic::Element && element_definitions == other.element_definitions
      end
    end

    def initialize(browser_element)
      @browser_element = browser_element
      @parent_element = self.class.parent_element
      @before_events = self.class.before_events
      @after_events = self.class.after_events
      @element_definitions = self.class.element_definitions.dup
      wrap_events(browser_element)
    end

    EVENT_TYPES.each do |method|
      define_method method do |*args|
        browser_element.send(method, *args)
      end
    end

    def method_missing(method, *args, &block)
      ElementContext.new(self).send(method, *args, &block)
    rescue ElementMissingException
      return super unless browser_element.respond_to?(method)
      browser_element.send(method, *args, &block)
    end

    def respond_to?(*args)
      super || element_context.respond_to?(*args) || browser_element.respond_to?(*args)
    end

    # @!method session
    # get the current session
    # @return [Session] returns the session of the parent page element.
    #  Capybara session
    def_delegator :parent_element, :session

    private

    def apply_hooks(raw_element:, capybara_method:, before_events:, after_events:)
      original_method = raw_element.method(capybara_method)
      this = self

      raw_element.define_singleton_method(capybara_method) do |*arguments, &block|
        before_events.each { |event| this.instance_exec(&event) }
        original_method.call(*arguments, &block)
        after_events.each { |event| this.instance_exec(&event) }
      end
    end

    def element_context
      ElementContext.new(self)
    end

    def wrap_events(raw_element)
      EVENT_TYPES.each do |action_method|
        next unless raw_element.respond_to?(action_method)
        apply_hooks(raw_element: raw_element,
                    capybara_method: action_method,
                    before_events: before_events,
                    after_events: after_events)
      end
    end
  end
end
