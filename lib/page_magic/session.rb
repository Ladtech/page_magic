require 'wait'
require 'forwardable'
require 'page_magic/matcher'
module PageMagic
  # class Session - coordinates access to the browser though page objects.
  class Session
    URL_MISSING_MSG = 'a path must be mapped or a url supplied'
    REGEXP_MAPPING_MSG = 'URL could not be derived because mapping contains Regexps'
    INVALID_MAPPING_MSG = 'mapping must be a string or regexp'

    extend Forwardable

    attr_reader :raw_session, :transitions, :base_url

    # Create a new session instance
    # @param [Object] capybara_session an instance of a capybara session
    # @param [String] base_url url to start the session at.
    def initialize(capybara_session, base_url = nil)
      @raw_session = capybara_session
      @base_url = base_url
      visit(url: base_url) if base_url
      @transitions = {}
    end

    # @return [Object] returns page object representing the currently loaded page on the browser. If no mapping
    # is found then nil returned
    def current_page
      mapping = find_mapped_page(current_url)
      @current_page = initialize_page(mapping) if mapping
      @current_page
    end

    # @return [String] path in the browser
    def current_path
      raw_session.current_path
    end

    # @return [String] full url in the browser
    def current_url
      raw_session.current_url
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
      @transitions = transitions.collect do |key, value|
        key = key.is_a?(Matcher) ? key : Matcher.new(key)
        [key, value]
      end.to_h
    end

    # @!method execute_script
    #  execute javascript on the browser
    #  @param [String] script the script to be executed
    #  @return [Object] object returned by the capybara execute_script method
    def_delegator :raw_session, :execute_script

    # proxies unknown method calls to the currently loaded page object
    # @return [Object] returned object from the page object method call
    def method_missing(name, *args, &block)
      current_page.send(name, *args, &block)
    end

    # @param args see {::Object#respond_to?}
    # @return [Boolean] true if self or the current page object responds to the give method name
    def respond_to?(*args)
      super || current_page.respond_to?(*args)
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
    def visit(page = nil, url: nil)
      if url
        raw_session.visit(url)
      elsif (mapping = transitions.key(page))
        fail InvalidURLException, REGEXP_MAPPING_MSG unless mapping.can_compute_uri?
        raw_session.visit(url(base_url, mapping.compute_uri))
      else
        fail InvalidURLException, URL_MISSING_MSG
      end
      @current_page = initialize_page(page) if page
      self
    end

    private

    def find_mapped_page(url)
      # TODO: - rank matches and choose highest rank? could be difficult because path match overalls everything?
      # TODO maybe find based on path, then rank of parameters and fragment?
      matches(url).first
    end

    def matches(url)
      transitions.keys.find_all { |matcher| matcher.match?(url) }.collect{|match| transitions[match]}
    end

    def initialize_page(page_class)
      page_class.new(self).execute_on_load
    end

    def url(base_url, path)
      path = path.sub(%r{^/}, '')
      base_url = base_url.sub(%r{/$}, '')
      "#{base_url}/#{path}"
    end
  end
end
