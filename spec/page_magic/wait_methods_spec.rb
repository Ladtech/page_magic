# frozen_string_literal: true

RSpec.describe PageMagic::WaitMethods do
  subject do
    Object.new.tap do |o|
      o.extend(described_class)
    end
  end

  let(:default_options) { { timeout_after: 0.1, retry_every: 0.05 } }

  it 'waits until the prescribed thing has happened' do
    expect { subject.wait_until(**default_options) { true } }.not_to raise_exception
  end

  it 'keeps trying for a specified period' do
    start_time = Time.now

    expect { subject.wait_until(**default_options) { false } }.to raise_exception PageMagic::TimeoutException

    expect(Time.now - default_options[:timeout_after]).to be > start_time
  end

  context 'timeout_after specified' do
    it 'throws an exception if when the prescribed action does not happen in time' do
      expect { subject.wait_until(**default_options) { false } }.to raise_error PageMagic::TimeoutException
    end
  end

  context 'retry time specified' do
    it 'retries at the given interval' do
      count = 0
      expect do
        subject.wait_until(timeout_after: default_options[:timeout_after] * 2, retry_every: 0.1) do
          count += 1
        end
      end.to raise_exception PageMagic::TimeoutException
      expect(count).to eq(2)
    end
  end
end
