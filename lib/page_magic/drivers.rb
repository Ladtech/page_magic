require 'page_magic/driver'
module PageMagic
  class Drivers
    def all
      @all ||=[]
    end

    def register(driver)
      all << driver
    end


    def find browser
      all.find{|driver|driver.support?(browser)}
    end

    def load path="#{__dir__}/drivers"
      require 'active_support/inflector'

      Dir["#{path}/*.rb"].each do |driver_file|
        require driver_file
        driver_name = File.basename(driver_file)[/(.*)\.rb$/, 1]
        register eval(driver_name.classify)
      end
    end

    def == other
      other.is_a?(Drivers) && other.all == other.all
    end
  end
end
