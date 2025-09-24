require 'spec_helper'

RSpec.describe DeTrack::Services::ClientSearcher do
  let(:clients) { TestDataHelper.load_sample_clients }
  let(:searcher) { described_class.new(clients) }

  describe '#initialize' do
    it 'handles nil clients gracefully' do
      searcher = described_class.new(nil)
      expect(searcher.count).to eq(0)
      expect(searcher).to be_empty
    end

    it 'accepts empty array' do
      searcher = described_class.new([])
      expect(searcher.count).to eq(0)
      expect(searcher).to be_empty
    end
  end

  describe '#search_by_name' do
    it 'finds clients with partial name match' do
      results = searcher.search_by_name('John')

      expect(results.length).to eq(2)
      expect(results.map(&:full_name)).to contain_exactly('John Doe', 'Alex Johnson')
    end

    it 'is case insensitive' do
      results = searcher.search_by_name('JOHN')

      expect(results.length).to eq(2)
      expect(results.map(&:full_name)).to contain_exactly('John Doe', 'Alex Johnson')
    end

    it 'matches last names' do
      results = searcher.search_by_name('Smith')

      expect(results.length).to eq(2)
      expect(results.map(&:full_name)).to contain_exactly('Jane Smith', 'Another Jane Smith')
    end

    it 'matches partial strings' do
      results = searcher.search_by_name('Michael')

      expect(results.length).to eq(2)
      expect(results.map(&:full_name)).to contain_exactly('Michael Williams', 'Michael Brown')
    end

    it 'returns empty array for no matches' do
      results = searcher.search_by_name('Nonexistent')

      expect(results).to be_empty
    end

    it 'handles nil query' do
      results = searcher.search_by_name(nil)

      expect(results).to be_empty
    end

    it 'handles empty query' do
      results = searcher.search_by_name('')

      expect(results).to be_empty
    end

    it 'handles whitespace-only query' do
      results = searcher.search_by_name('   ')

      expect(results).to be_empty
    end

    it 'strips whitespace from query' do
      results = searcher.search_by_name('  John  ')

      expect(results.length).to eq(2)
    end

    it 'returns identical results for different case variations of same query' do
      # Test that 'John', 'john', and 'JOHN' return exactly the same results
      results_mixed = searcher.search_by_name('John')
      results_lower = searcher.search_by_name('john')
      results_upper = searcher.search_by_name('JOHN')

      expect(results_mixed).to eq(results_lower)
      expect(results_lower).to eq(results_upper)
      expect(results_mixed).to eq(results_upper)

      # Verify all return the expected clients
      expected_names = ['John Doe', 'Alex Johnson']
      expect(results_mixed.map(&:full_name)).to contain_exactly(*expected_names)
      expect(results_lower.map(&:full_name)).to contain_exactly(*expected_names)
      expect(results_upper.map(&:full_name)).to contain_exactly(*expected_names)
    end
  end

  describe '#search_by_exact_name' do
    it 'finds clients with exact name match' do
      results = searcher.search_by_exact_name('Sebastian Allen')

      expect(results.length).to eq(1)
      expect(results.first.full_name).to eq('Sebastian Allen')
    end

    it 'is case insensitive' do
      results = searcher.search_by_exact_name('JANE SMITH')

      expect(results.length).to eq(1)
      expect(results.first.full_name).to eq('Jane Smith')
    end

    it 'does not match partial names' do
      results = searcher.search_by_exact_name('John')

      expect(results).to be_empty
    end

    it 'handles edge cases' do
      expect(searcher.search_by_exact_name(nil)).to be_empty
      expect(searcher.search_by_exact_name('')).to be_empty
      expect(searcher.search_by_exact_name('   ')).to be_empty
    end
  end

  describe '#search_by_id' do
    it 'finds client by ID' do
      client = searcher.search_by_id(22)

      expect(client).not_to be_nil
      expect(client.id).to eq(22)
      expect(client.full_name).to eq('Sebastian Allen')
    end

    it 'returns nil for non-existent ID' do
      client = searcher.search_by_id(999)

      expect(client).to be_nil
    end

    it 'handles invalid IDs' do
      expect(searcher.search_by_id(0)).to be_nil
      expect(searcher.search_by_id(-1)).to be_nil
      expect(searcher.search_by_id('1')).to be_nil
      expect(searcher.search_by_id(nil)).to be_nil
    end
  end

  describe '#search_by_email' do
    it 'finds clients by email' do
      results = searcher.search_by_email('john.doe@gmail.com')

      expect(results.length).to eq(1)
      expect(results.first.full_name).to eq('John Doe')
    end

    it 'is case insensitive' do
      results = searcher.search_by_email('JOHN.DOE@GMAIL.COM')

      expect(results.length).to eq(1)
      expect(results.first.full_name).to eq('John Doe')
    end

    it 'returns empty array for no matches' do
      results = searcher.search_by_email('nonexistent@example.com')

      expect(results).to be_empty
    end

    it 'handles edge cases' do
      expect(searcher.search_by_email(nil)).to be_empty
      expect(searcher.search_by_email('')).to be_empty
      expect(searcher.search_by_email('   ')).to be_empty
    end

    it 'strips whitespace' do
      results = searcher.search_by_email('  john.doe@gmail.com  ')

      expect(results.length).to eq(1)
    end

    it 'returns identical results for different case variations of same email' do
      # Test that different case variations return exactly the same results
      results_lower = searcher.search_by_email('john.doe@gmail.com')
      results_mixed = searcher.search_by_email('John.Doe@Gmail.com')
      results_upper = searcher.search_by_email('JOHN.DOE@GMAIL.COM')

      expect(results_lower).to eq(results_mixed)
      expect(results_mixed).to eq(results_upper)
      expect(results_lower).to eq(results_upper)

      # Verify all return the expected client
      expect(results_lower.length).to eq(1)
      expect(results_mixed.length).to eq(1)
      expect(results_upper.length).to eq(1)
      expect(results_lower.first.full_name).to eq('John Doe')
      expect(results_mixed.first.full_name).to eq('John Doe')
      expect(results_upper.first.full_name).to eq('John Doe')
    end
  end

  describe '#count' do
    it 'returns the number of clients' do
      expect(searcher.count).to eq(35)
    end
  end

  describe '#empty?' do
    it 'returns false when there are clients' do
      expect(searcher).not_to be_empty
    end

    it 'returns true when there are no clients' do
      empty_searcher = described_class.new([])
      expect(empty_searcher).to be_empty
    end
  end
end