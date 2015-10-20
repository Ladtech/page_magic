require 'wait'
module PageMagic
  class InvalidURLException < Exception; end

  class Session
    URL_MISSING_MSG = 'a url must be specified as either a parameter or on the page class'
    REGEXP_MAPPING_MSG = 'URL could not be derived because mapping is a Regexp'

    attr_accessor :current_page, :raw_session, :transitions

    def initialize(browser, url = nil)
      @raw_session = browser
      raw_session.visit(url) if url
      @transitions = {}
    end

    def define_page_mappings(transitions)
      @transitions = transitions
    end

    def current_page
      if transitions
        mapping = find_mapped_page(current_path)
        @current_page = mapping.new(self) if mapping
      end
      @current_page
    end

    def find_mapped_page(path)
      mapping = transitions.keys.find do |key|
        string_matches?(path, key)
      end
      transitions[mapping]
    end

    def visit(page, use_page_mappings: false)
      if page.ancestors.include?(PageMagic)
        page = page
        if page.path && !use_page_mappings
          raw_session.visit("#{current_url}#{page.path}")
        elsif path = transitions.key(page)
          fail InvalidURLException, REGEXP_MAPPING_MSG if path.is_a?(Regexp)
          raw_session.visit("#{current_url}#{path}")
        else
          fail InvalidURLException, URL_MISSING_MSG
        end
        @current_page = page.new self
      end
      self
    end

    def current_path
      raw_session.current_path
    end

    def current_url
      raw_session.current_url
    end

    def wait_until(&block)
      @wait ||= Wait.new
      @wait.until(&block)
    end

    def method_missing(name, *args, &block)
      current_page.send(name, *args, &block)
    end

    def respond_to?(*args)
      super || current_page.respond_to?(*args)
    end

    private

    def string_matches?(string, matcher)
      if matcher.is_a?(Regexp)
        string =~ matcher
      elsif matcher.is_a?(String)
        string == matcher
      else
        false
      end
    end
  end
end
