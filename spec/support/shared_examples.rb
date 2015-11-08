module PageMagic
  shared_examples 'session accessor' do
    it 'includes session methods' do
      expect(described_class.included_modules).to include(SessionMethods)
    end
  end

  shared_examples 'element watcher' do
    it 'includes watchers' do
      expect(described_class.included_modules).to include(Watchers)
    end
  end

  shared_examples 'waiter' do
    it 'includes waiters' do
      expect(described_class.included_modules).to include(Waiters)
    end
  end
end
