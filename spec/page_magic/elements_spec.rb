# rubocop:disable Metrics/ModuleLength
module PageMagic
  describe Elements do
    include_context :nested_elements_html

    let(:page) { double(init: nested_elements_node) }

    subject do
      Class.new do
        extend Elements
        include Element::Locators
      end
    end

    # subject { Element.new(page, type: :element, selector: { id: 'parent' }) }
    let(:child_element) { Element.new(type: :element, selector: { id: 'child' }) }

    let(:child_selector) { child_element.selector }

    def expected_element(type)
      Element.new(type: type, selector: child_selector)
    end

    describe '#element' do
      it 'uses the supplied name' do
        subject.text_field :alias, child_selector
        expect(subject.new.element_by_name(:alias)).to eq(expected_element(:text_field))
      end

      it 'sets the selector' do
        subject.text_field :alias, child_selector
        set_selector = subject.new.element_by_name(:alias).selector
        expect(set_selector).to eq(expected_element(:text_field).selector)
      end

      context 'complex elements' do
        let!(:section_class) do
          Class.new(Element) do
            def self.name
              'PageSection'
            end
          end
        end

        context 'using a predefined class' do
          it 'should add an element using that class section' do
            subject.element section_class, :page_section, child_selector
            expect(subject.elements(subject).first).to eq(expected_element(:element))
          end

          context 'with no selector supplied' do
            it 'defaults the selector to the one on the class' do
              section_class.selector child_selector
              subject.element section_class, :alias
              expect(subject.elements(subject).first.selector).to eq(child_selector)
            end
          end

          context 'with no name supplied' do
            it 'should default to the name of the class if one is not supplied' do
              subject.element section_class, child_selector
              expect(subject.new.element_by_name(:page_section)).to eq(expected_element(:element))
            end
          end
        end
      end

      context 'using a block' do
        # TODO: - this isn't going to be possible use browser_element in on_load instead? or helper methods
        # context 'browser_element' do
        #   it 'should be assigned when selector is passed to section method' do
        #     expected_element = child_element.browser_element.native
        #
        #     subject.element :page_section, child_selector do
        #       extend RSpec::Matchers
        #       expect(browser_element.native).to eq(expected_element)
        #     end
        #
        #     subject.new.element_by_name(:page_section)
        #   end
        #
        #   it 'should be assigned when selector is defined in the block passed to the section method' do
        #     expected_element = child_element
        #
        #     subject.element :page_section do
        #       selector expected_element.selector
        #       extend RSpec::Matchers
        #       expect(browser_element.native).to eq(expected_element.browser_element.native)
        #     end
        #
        #     subject.new.elements(subject)
        #   end
        # end

        it 'should pass args through to the block' do
          subject.element :page_section, child_selector do |arg|
            arg[:passed_through] = true
          end

          arg = {}
          subject.elements(subject, arg)
          expect(arg[:passed_through]).to eq(true)
        end
      end

      describe 'location' do
        context 'a prefetched object' do
          it 'should add a section' do
            expected_section = Element.new(type: :element,
                                           prefetched_browser_element: :object)
            subject.element :page_section, :object
            expect(expected_section).to eq(subject.elements(subject).first)
          end
        end
      end

      describe 'restrictions' do
        subject do
          Class.new.tap do |clazz|
            clazz.extend(described_class)
          end
        end

        it 'should not allow method names that match element names' do
          expect do
            subject.class_eval do
              link(:hello, text: 'world')

              def hello
              end
            end
          end.to raise_error(InvalidMethodNameException)
        end

        it 'should not allow element names that match method names' do
          expect do
            subject.class_eval do
              def hello
              end

              link(:hello, text: 'world')
            end
          end.to raise_error(InvalidElementNameException)
        end

        it 'should not allow duplicate element names' do
          expect do
            subject.class_eval do
              link(:hello, text: 'world')
              link(:hello, text: 'world')
            end
          end.to raise_error(InvalidElementNameException)
        end

        it 'should not evaluate the elements when applying naming checks' do
          subject.class_eval do
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
        subject.text_field :alias, child_selector
        first = subject.new.element_by_name(:alias)
        second = subject.new.element_by_name(:alias)
        expect(first).to_not equal(second)
      end
    end
  end
end
