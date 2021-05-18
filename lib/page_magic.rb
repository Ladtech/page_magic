# frozen_string_literal: true

$LOAD_PATH.unshift(File.dirname(__FILE__).to_s)
require 'capybara'
require 'page_magic/exceptions'
require 'page_magic/wait_methods'
require 'page_magic/watchers'
require 'page_magic/session'
require 'page_magic/session_methods'
require 'page_magic/elements'
require 'page_magic/element_context'
require 'page_magic/element'
require 'page_magic/class_methods'
require 'page_magic/instance_methods'
require 'page_magic/drivers'

# module PageMagic - PageMagic is an api for modelling pages in a website.
module PageMagic
  extend SingleForwardable

  # @!method matcher
  # define match critera for loading a page object class
  # @see Matcher#initialize
  # @return [Matcher]
  def_delegator Matcher, :new, :matcher

  class << self
    # @return [Drivers] registered drivers
    def drivers
      @drivers ||= Drivers.new.tap(&:load)
    end

    def included(clazz)
      clazz.class_eval do
        include(InstanceMethods)
        extend ClassMethods
        extend Elements
      end
    end

    # Create a more complex mapping to identify when a page should be loaded
    # @example
    #   PageMagic.mapping '/', parameters: {project: 'page_magic'}, fragment: 'display'
    # @see Matchers#initialize
    def mapping(path = nil, parameters: nil, fragment: nil)
      Matcher.new(path, parameters: parameters, fragment: fragment)
    end

    # Visit this page based on the class level registered url
    # @param [Object] application rack application (optional)
    # @param [Symbol] browser name of browser
    # @param [String] url url to start the session on
    # @param [Hash] options browser driver specific options
    # @return [Session] configured session
    def session(url: nil, application: nil, browser: :rack_test, options: {})
      driver = drivers.find(browser)
      raise UnsupportedBrowserException unless driver

      Capybara.register_driver browser do |app|
        driver.build(app, browser: browser, options: options)
      end

      Session.new(Capybara::Session.new(browser, application), url)
    end
  end
end
