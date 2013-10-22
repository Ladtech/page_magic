require 'spec_helper'

describe 'page magic' do

  include_context :webapp

  let(:my_page_class) do
    Class.new do
      include PageMagic
      url '/page1'
      link(:next, :text => "next page")
    end
  end

  before :each do
    @page = my_page_class.new
  end


  describe 'browser integration' do
    it "should use capybara's default session if a one is not supplied" do
      Capybara.default_driver = :rack_test
      my_page_class.new.browser.mode.should == :rack_test
    end
  end

  describe 'visit' do
    it 'should go to the page' do
      @page.visit
      @page.current_path.should == '/page1'
    end
  end

  it 'can have fields' do
    @page.elements(@browser).should == [PageMagic::PageElement.new(:click_create,:button, :text => "create user")]
  end

  it 'should copy fields on to element' do
    @page.elements(@browser).first.should_not equal(my_page_class.new(@browser).elements(@browser).first)
  end

  it 'gives access to the page text' do
    @page.visit.text.should == 'next page'
  end

  it 'should access a field' do
    @page.visit
    @page.click_next
    @page.text.should == 'page 2 content'
  end
end