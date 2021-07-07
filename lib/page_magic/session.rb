# frozen_string_literal: true

require 'forwardable'
require_relative 'transitions'

module PageMagic
  # class Session - coordinates access to the browser though page objects.
  class Session
    URL_MISSING_MSG = 'a path must be mapped or a url supplied'

    INVALID_MAPPING_MSG = 'mapping must be a string or regexp'
    UNSUPPORTED_OPERATION_MSG = 'execute_script not supported by driver'

    extend Forwardable

    attr_reader :raw_session, :transitions, :base_url

    # Create a new session instance
    # @param [Object] capybara_session an instance of a capybara session
    # @param [String] base_url url to start the session at.
    #

    def initialize(capybara_session, base_url = nil)
      @raw_session = capybara_session
      @base_url = base_url
      define_page_mappings({})
    end

    # @return [Object] returns page object representing the currently loaded page on the browser. If no mapping
    # is found then nil returned
    def current_page
      mapping = transitions.mapped_page(current_url)
      @current_page = initialize_page(mapping) if mapping
      @current_page
    end

    # Map paths to Page classes. The session will auto load page objects from these mapping when
    # the {Session#current_path}
    # is matched.
    # @example
    #   self.define_page_mappings '/' => HomePage, %r{/messages/d+}
    # @param [Hash] transitions - paths mapped to page classes
    # @option transitions [String] path as literal
    # @option transitions [Regexp] path as a regexp for dynamic matching.
    def define_page_mappings(transitions)
      @transitions = Transitions.new(transitions)
    end

    def is_a?(klass)
      return true if klass == Capybara::Session

      super
    end

    # proxies unknown method calls to the currently loaded page object
    # @return [Object] returned object from the page object method call
    def method_missing(name, *args, &block)
      return raw_session.send(name, *args, &block) if raw_session.respond_to?(name)

      current_page.send(name, *args, &block)
    end

    def on?(page_class)
      current_page.is_a?(page_class)
    end

    # @param args see {::Object#respond_to?}
    # @return [Boolean] true if self or the current page object responds to the give method name
    def respond_to_missing?(*args)
      super || current_page.respond_to?(*args) || raw_session.respond_to?(*args)
    end

    # Direct the browser to the given page or url. {Session#current_page} will be set be an instance of the given/mapped
    # page class
    # @overload visit(page: page_object)
    #  @param [Object] page page class. The required url will be generated using the session's base url and the mapped
    #   path
    # @overload visit(url: url)
    #  @param [String] url url to be visited.
    # @overload visit(page: page_class, url: url)
    #  @param [String] url url to be visited.
    #  @param [Object] page the supplied page class will be instantiated to be used against the given url.
    # @raise [InvalidURLException] if a page is supplied and there isn't a mapped path for it
    # @raise [InvalidURLException] if neither a page or url are supplied
    # @raise [InvalidURLException] if the mapped path for a page is a Regexp
    # @return [PageMagic::Session] - returns self
    def visit(page_or_url = nil, url: nil)
      url ||= page_or_url.is_a?(String) ? page_or_url : transitions.url_for(page_or_url, base_url: base_url)

      raise InvalidURLException, URL_MISSING_MSG unless url

      raw_session.visit(url)
      @current_page = initialize_page(page_or_url) unless page_or_url.is_a?(String)
      self
    end

    private

    def initialize_page(page_class)
      page_class.new(self).execute_on_load
    end
  end
end
