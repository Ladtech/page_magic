# frozen_string_literal: true
RSpec.describe PageMagic::Drivers::Poltergeist do
  it "is capybara's poltergeist driver" do
    driver = described_class.build(:app, browser: :poltergeist, options: {})
    expect(driver).to be_a(Capybara::Poltergeist::Driver)
  end
end
