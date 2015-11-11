require 'forwardable'
require 'page_magic/element/selector_methods'
require 'page_magic/element/locators'
require 'page_magic/element/selector'
require 'page_magic/element/query'
module PageMagic
  # class Element - represents an element in a html page.
  class Element
    EVENT_TYPES = [:set, :select, :select_option, :unselect_option, :click]
    DEFAULT_HOOK = proc {}.freeze

    include SelectorMethods, Watchers, SessionMethods, WaitMethods, Locators
    extend Elements, SelectorMethods, Forwardable

    attr_reader :type, :name, :parent_page_element, :browser_element, :before_events, :after_events

    class << self
      # Get/Sets the block of code to be run after an event is triggered on an element. See {EVENT_TYPES} for the list of
      # events that this block will be triggered for. The block is run in the scope of the element object
      def after_events(&block)
        return @after_hook unless block
        @after_hook = block
      end

      # Get/Sets the block of code to be run before an event is triggered on an element. See {EVENT_TYPES} for the list of
      # events that this block will be triggered for. The block is run in the scope of the element object
      def before_events(&block)
        return @before_hook unless block
        @before_hook = block
      end
    end

    def initialize(type: :element, selector: {}, prefetched_browser_element: nil, &block)
      @browser_element = prefetched_browser_element
      @selector = selector

      @before_events = self.class.before_events || DEFAULT_HOOK
      @after_events = self.class.after_events || DEFAULT_HOOK
      @type = type
      @element_definitions = self.class.element_definitions.dup
      expand(&block) if block
    end

    # @return [Object] the Capybara browser element that this element definition is tied to.
    def init(parent_page_element)
      return @browser_element if @browser_element
      @parent_page_element = parent_page_element

      fail UndefinedSelectorException, 'Pass a locator/define one on the class' if selector.empty?

      query = Query.find(type).build(query_selector, query_options)

      @browser_element = parent_page_element.browser_element.find(*query).tap do |raw_element|
        wrap_events(raw_element)
      end
    end

    # expand the element definition by evaluating the given block in the scope of this object
    # @param [*Object] args list of arguments to be supplied to the given block
    def expand(*args, &block)
      instance_exec(*args, &block)
      self
    end

    def method_missing(method, *args, &block)
      ElementContext.new(self).send(method, args.first, &block)
    rescue ElementMissingException
      return super unless browser_element.respond_to?(method)
      browser_element.send(method, *args, &block)
    end

    def respond_to?(*args)
      super || element_context.respond_to?(*args) || browser_element.respond_to?(*args)
    end

    # @return [Array] class level defined element definitions
    def element_definitions
      self.class.element_definitions
    end

    # @!method session
    # get the current session
    # @return [Session] returns the session of the parent page element.
    #  Capybara session
    def_delegator :parent_page_element, :session

    def ==(other)
      return false unless other.is_a?(Element)
      this = [type, selector, before_events, after_events]
      this == [other.type, other.selector, other.before_events, other.after_events]
    end

    private

    def apply_hooks(raw_element:, capybara_method:, before_hook:, after_hook:)
      original_method = raw_element.method(capybara_method)
      this = self

      raw_element.define_singleton_method(capybara_method) do |*arguments, &block|
        this.instance_exec(&before_hook)
        original_method.call(*arguments, &block)
        this.instance_exec(&after_hook)
      end
    end

    def element_context
      ElementContext.new(self)
    end

    def query_options
      selector.dup.delete_if { |key, _value| key == selector.keys.first }
    end

    def query_selector
      Hash[*selector.first]
    end

    def wrap_events(raw_element)
      EVENT_TYPES.each do |action_method|
        next unless raw_element.respond_to?(action_method)
        apply_hooks(raw_element: raw_element,
                    capybara_method: action_method,
                    before_hook: before_events,
                    after_hook: after_events)
      end
    end
  end
end
