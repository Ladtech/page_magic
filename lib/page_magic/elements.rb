module PageMagic
  module Elements
    class InvalidElementNameException < Exception
    end

    class InvalidMethodNameException < Exception
    end

    def self.extended clazz
      clazz.class_eval do
        attr_reader :browser_element

        def elements browser_element, *args
          self.class.elements browser_element, *args
        end

        def element_definitions
          self.class.element_definitions
        end
      end
    end

    def method_added method
      raise InvalidMethodNameException, "method name matches element name" if element_definitions[method]
    end


    def elements(browser_element, *args)
      element_definitions.values.collect { |definition| definition.call(browser_element, *args) }
    end

    def elements?
      !element_definitions.empty?
    end

    TYPES = [:element, :text_field, :button, :link, :checkbox, :select_list, :radios, :textarea]
    TYPES.each do |type|
      define_method type do |*args, &block|
        name, selector = args
        add_element_definition(name) do |parent_element|
          Element.new(name, parent_element, type, selector, &block)
        end
      end
    end

    def underscore string
      string.gsub(/::/, '/').
          gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').
          gsub(/([a-z\d])([A-Z])/, '\1_\2').
          tr("-", "_").
          downcase
    end

    def section *args, &block
      first_arg = args.first
      if first_arg.is_a?(Symbol)
        name, selector = args

        add_element_definition(name) do |parent_browser_element, *args_for_section|
          page_section = PageMagic::Element.new name, parent_browser_element, :section, selector
          page_section.instance_exec *args_for_section, &(block || Proc.new {})
          page_section
        end


      elsif first_arg < PageMagic::Element
        section_class, name, selector = args

        unless selector
          selector = name
          name = nil
        end

        name = underscore(section_class.name) unless name
        add_element_definition(name) do |parent_browser_element|
          section_class.new(name, parent_browser_element, :section, selector)
        end

      end
    end

    def add_element_definition name, &block
      raise InvalidElementNameException, "duplicate page element defined" if element_definitions[name]

      methods = respond_to?(:instance_methods) ? instance_methods : methods()
      raise InvalidElementNameException, "a method already exists with this method name" if methods.find { |method| method == name }

      element_definitions[name] = block
    end

    def element_definitions
      @element_definitions ||= {}
    end
  end
end