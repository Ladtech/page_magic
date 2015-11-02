$LOAD_PATH.unshift("#{File.dirname(__FILE__)}")
require 'capybara'
require 'page_magic/exceptions'
require 'page_magic/session'
require 'page_magic/instance_methods'
require 'page_magic/elements'
require 'page_magic/element_context'
require 'page_magic/element'
require 'page_magic/drivers'

# module PageMagic - PageMagic is an api for modelling pages in a website.
module PageMagic
  class << self
    def drivers
      @drivers ||= Drivers.new.tap(&:load)
    end

    def session(application: nil, browser: :rack_test, url:, options: {})
      driver = drivers.find(browser)
      fail UnspportedBrowserException unless driver

      Capybara.register_driver browser do |app|
        driver.build(app, browser: browser, options: options)
      end

      Session.new(Capybara::Session.new(browser, application), url)
    end

    def included(clazz)
      clazz.class_eval do
        def self.url(url = nil)
          @url = url if url
          @url
        end

        include(InstanceMethods)
        extend(Elements)
      end
    end
  end
end
