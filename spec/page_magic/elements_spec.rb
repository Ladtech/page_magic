# rubocop:disable Metrics/ModuleLength
module PageMagic
  describe Elements do
    let(:page_elements) do
      Class.new.tap do |clazz|
        clazz.extend(described_class)
      end
    end

    let(:selector) { { id: 'id' } }
    let(:browser_element) { double('browser_element', find: :browser_element) }
    let(:parent_page_element) do
      double('parent_page_element', browser_element: browser_element)
    end

    describe '#element' do
      it 'uses the supplied name' do
        expected_element = Element.new(parent_page_element, type: :text_field, selector: selector)
        page_elements.text_field :alias, selector
        expect(page_elements.element_definitions[:alias].call(parent_page_element)).to eq(expected_element)
      end

      it 'sets the parent element' do
        page_elements.element :page_section, selector
        section = page_elements.element_definitions[:page_section].call(:parent)
        expect(section.parent_page_element).to eq(:parent)
      end

      context 'using a selector' do
        it 'should add an element' do
          expected_element = Element.new(parent_page_element, type: :text_field, selector: selector)
          page_elements.text_field :name, selector
          expect(page_elements.element_definitions[:name].call(parent_page_element)).to eq(expected_element)
        end
      end

      context 'complex elements' do
        let!(:section_class) do
          Class.new(Element) do
            def ==(other)
              other.name == name &&
                other.browser_element == browser_element
            end
          end
        end

        context 'using a predefined class' do
          it 'should add an element using that class section' do
            expected_section = section_class.new(parent_page_element, type: :section, selector: selector)

            page_elements.element section_class, :page_section, selector
            expect(page_elements.elements(parent_page_element).first).to eq(expected_section)
          end

          context 'with no selector supplied' do
            it 'defaults the selector to the one on the class' do
              section_class.selector selector
              page_elements.element section_class, :alias
              expect(page_elements.elements(parent_page_element).first.selector).to eq(selector)
            end
          end

          context 'with no name supplied' do
            it 'should default to the name of the class if one is not supplied' do
              expected_element = Element.new(parent_page_element, selector: selector)
              allow(section_class).to receive(:name).and_return('PageSection')
              page_elements.element section_class, selector
              expect(page_elements.element_definitions[:page_section].call(parent_page_element)).to eq(expected_element)
            end
          end
        end
      end

      context 'using a block' do
        context 'browser_element' do
          before :each do
            @browser = double('browser')
            @element = double('element')
            @parent_page_element = double('parent_page_element')
            allow(@parent_page_element).to receive(:browser_element).and_return(@browser)
            expect(@browser).to receive(:find).with(:selector).and_return(@element)
          end

          it 'should be assigned when selector is passed to section method' do
            element = @element

            page_elements.element :page_section, css: :selector do
              extend RSpec::Matchers
              expect(browser_element).to eq(element)
            end

            page_elements.element_definitions[:page_section].call(@parent_page_element)
          end

          it 'should be assigned when selector is defined in the block passed to the section method' do
            element = @element

            page_elements.element :page_section do
              selector css: :selector
              extend RSpec::Matchers
              expect(browser_element).to eq(element)
            end

            page_elements.elements(@parent_page_element, nil)
          end
        end

        it 'should pass args through to the block' do
          page_elements.element :page_section, css: '.blah' do |arg|
            arg[:passed_through] = true
          end

          arg = {}
          browser = double('browser', find: :browser_element)
          parent_page_element = double('parent_browser_element', browser_element: browser)
          page_elements.elements(parent_page_element, arg)
          expect(arg[:passed_through]).to eq(true)
        end

        it 'should return your a copy of the core definition' do
          page_elements.element :page_section, selector
          first = page_elements.element_definitions[:page_section].call(parent_page_element)
          second = page_elements.element_definitions[:page_section].call(parent_page_element)
          expect(first).to_not equal(second)
        end
      end

      describe 'location' do
        context 'a prefetched object' do
          it 'should add a section' do
            expected_section = Element.new(parent_page_element,
                                           type: :element,
                                           prefetched_browser_element: :object)
            page_elements.element :page_section, :object
            expect(expected_section).to eq(page_elements.elements(parent_page_element).first)
          end
        end
      end

      describe 'restrictions' do
        it 'should not allow method names that match element names' do
          expect do
            page_elements.class_eval do
              link(:hello, text: 'world')

              def hello
              end
            end
          end.to raise_error(InvalidMethodNameException)
        end

        it 'should not allow element names that match method names' do
          expect do
            page_elements.class_eval do
              def hello
              end

              link(:hello, text: 'world')
            end
          end.to raise_error(InvalidElementNameException)
        end

        it 'should not allow duplicate element names' do
          expect do
            page_elements.class_eval do
              link(:hello, text: 'world')
              link(:hello, text: 'world')
            end
          end.to raise_error(InvalidElementNameException)
        end

        it 'should not evaluate the elements when applying naming checks' do
          page_elements.class_eval do
            link(:link1, :selector) do
              fail('should not have been evaluated')
            end
            link(:link2, :selector)
          end
        end
      end
    end

    describe '#element_definitions' do
      it 'should return your a copy of the core definition' do
        page_elements.text_field :name, selector
        first = page_elements.element_definitions[:name].call(parent_page_element)
        second = page_elements.element_definitions[:name].call(parent_page_element)
        expect(first).to_not equal(second)
      end
    end
  end
end
