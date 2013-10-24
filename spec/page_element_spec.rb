require 'spec_helper'
require 'sinatra'


describe 'Page elements' do

  before :each do
    Capybara.app = Class.new(Sinatra::Base) do
      get '/' do
        <<-HTML
          <label>enter text
          <input id='field_id' name='field_name' class='input_class' type='text' value='filled in'/>
          </label>
          <a id=my_link href='#'>my link</a>
        HTML
      end
    end

    Capybara.current_session.visit('/')
  end
  describe 'location' do
    let!(:browser) { double('browser') }

    it 'should locate an element using its id' do
      element = PageMagic::PageElement.new(:my_input,Capybara.current_session, :text_field, id:'field_id').locate
      element.value == 'filled in'
    end

    it 'should locate an element using its name' do
      element = PageMagic::PageElement.new(:my_input,Capybara.current_session, :text_field, name:'field_name').locate
      element.value == 'filled in'
    end

    it 'should locate a link using its text' do
      element = PageMagic::PageElement.new(:my_link,Capybara.current_session, :link, text: 'my link').locate
      element[:id].should == 'my_link'
    end

    it 'should locate an element using its label' do
      element = PageMagic::PageElement.new(:my_link,Capybara.current_session, :link, label: 'enter text').locate
      element[:id].should == 'field_id'
    end

    it 'should raise an exception when finding another element using its text' do
      expect{PageMagic::PageElement.new(:my_link,Capybara.current_session, :text_field, text: 'my link').locate}.to raise_error(PageMagic::UnsupportedSelectorException)
    end

    it 'should locate an element using css' do
      element = PageMagic::PageElement.new(:my_link,Capybara.current_session, :link, css: "input[name='field_name']").locate
      element[:id].should == 'field_id'
    end

    it 'should raise errors for unsupported selectors' do
      expect{PageMagic::PageElement.new(:my_link,Capybara.current_session, :link, unsupported:"").locate}.to raise_error(PageMagic::UnsupportedSelectorException)
    end



    it 'should return the browser element if a selector was not specified' do
      PageMagic::PageElement.new(:help, browser, :link, nil).locate.should == browser
    end

    it 'backs up the locate method so that it can be overridden' do
      PageMagic::PageElement.new(:help, :link).methods.should include(:inherited_locate_method)
    end

    it 'should return a prefetched value' do
      session = double("session")
      PageMagic::PageElement.new(:help, session, :link, "prefetched text").locate.should == session
    end
  end

end
