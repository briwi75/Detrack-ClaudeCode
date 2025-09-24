require 'spec_helper'

RSpec.describe DeTrack::Services::DuplicateDetector do
  let(:clients_with_duplicates) { TestDataHelper.load_sample_clients }

  let(:clients_without_duplicates) do
    # Create a subset with unique emails for testing
    [
      DeTrack::Models::Client.new(id: 1, full_name: 'John Doe', email: 'john.doe@gmail.com'),
      DeTrack::Models::Client.new(id: 22, full_name: 'Sebastian Allen', email: 'sebastian.allen@hotmail.com'),
      DeTrack::Models::Client.new(id: 7, full_name: 'Olivia Miller', email: 'olivia.miller@protonmail.com')
    ]
  end

  describe '#initialize' do
    it 'handles nil clients gracefully' do
      detector = described_class.new(nil)
      expect(detector.find_duplicate_emails).to be_empty
    end

    it 'accepts empty array' do
      detector = described_class.new([])
      expect(detector.find_duplicate_emails).to be_empty
    end
  end

  describe '#find_duplicate_emails' do
    context 'with duplicate emails' do
      let(:detector) { described_class.new(clients_with_duplicates) }

      it 'finds all duplicate email groups' do
        duplicates = detector.find_duplicate_emails

        expect(duplicates.keys).to contain_exactly('jane.smith@yahoo.com')
        expect(duplicates['jane.smith@yahoo.com'].length).to eq(2)
      end

      it 'sorts clients by ID within each duplicate group' do
        duplicates = detector.find_duplicate_emails

        jane_smith_duplicates = duplicates['jane.smith@yahoo.com']
        expect(jane_smith_duplicates.map(&:id)).to eq([2, 15])
        expect(jane_smith_duplicates.map(&:full_name)).to eq(['Jane Smith', 'Another Jane Smith'])
      end
    end

    context 'without duplicate emails' do
      let(:detector) { described_class.new(clients_without_duplicates) }

      it 'returns empty hash' do
        duplicates = detector.find_duplicate_emails

        expect(duplicates).to be_empty
      end
    end
  end

  describe '#has_duplicates?' do
    it 'returns true when duplicates exist' do
      detector = described_class.new(clients_with_duplicates)
      expect(detector.has_duplicates?).to be true
    end

    it 'returns false when no duplicates exist' do
      detector = described_class.new(clients_without_duplicates)
      expect(detector.has_duplicates?).to be false
    end

    it 'returns false for empty client list' do
      detector = described_class.new([])
      expect(detector.has_duplicates?).to be false
    end
  end

  describe '#duplicate_count' do
    it 'returns total number of clients with duplicate emails' do
      detector = described_class.new(clients_with_duplicates)
      expect(detector.duplicate_count).to eq(2)
    end

    it 'returns 0 when no duplicates exist' do
      detector = described_class.new(clients_without_duplicates)
      expect(detector.duplicate_count).to eq(0)
    end
  end

  describe '#unique_duplicate_emails' do
    it 'returns list of email addresses that have duplicates' do
      detector = described_class.new(clients_with_duplicates)
      emails = detector.unique_duplicate_emails

      expect(emails).to contain_exactly('jane.smith@yahoo.com')
    end

    it 'returns empty array when no duplicates exist' do
      detector = described_class.new(clients_without_duplicates)
      emails = detector.unique_duplicate_emails

      expect(emails).to be_empty
    end
  end

  describe '#find_duplicates_for_email' do
    let(:detector) { described_class.new(clients_with_duplicates) }

    it 'finds all clients with specific email address' do
      clients = detector.find_duplicates_for_email('jane.smith@yahoo.com')

      expect(clients.length).to eq(2)
      expect(clients.map(&:full_name)).to contain_exactly('Jane Smith', 'Another Jane Smith')
    end

    it 'is case insensitive' do
      clients = detector.find_duplicates_for_email('JANE.SMITH@YAHOO.COM')

      expect(clients.length).to eq(2)
    end

    it 'returns empty array for non-existent email' do
      clients = detector.find_duplicates_for_email('nonexistent@example.com')

      expect(clients).to be_empty
    end

    it 'handles edge cases' do
      expect(detector.find_duplicates_for_email(nil)).to be_empty
      expect(detector.find_duplicates_for_email('')).to be_empty
      expect(detector.find_duplicates_for_email('   ')).to be_empty
    end

    it 'strips whitespace' do
      clients = detector.find_duplicates_for_email('  jane.smith@yahoo.com  ')

      expect(clients.length).to eq(2)
    end

    it 'returns single client for unique email' do
      clients = detector.find_duplicates_for_email('john.doe@gmail.com')

      expect(clients.length).to eq(1)
      expect(clients.first.full_name).to eq('John Doe')
    end

    it 'returns identical results for different case variations of same email' do
      # Test that different case variations return exactly the same results
      results_lower = detector.find_duplicates_for_email('jane.smith@yahoo.com')
      results_mixed = detector.find_duplicates_for_email('Jane.Smith@Yahoo.com')
      results_upper = detector.find_duplicates_for_email('JANE.SMITH@YAHOO.COM')

      expect(results_lower).to eq(results_mixed)
      expect(results_mixed).to eq(results_upper)
      expect(results_lower).to eq(results_upper)

      # Verify all return the expected duplicates
      expected_names = ['Jane Smith', 'Another Jane Smith']
      expect(results_lower.map(&:full_name)).to contain_exactly(*expected_names)
      expect(results_mixed.map(&:full_name)).to contain_exactly(*expected_names)
      expect(results_upper.map(&:full_name)).to contain_exactly(*expected_names)
    end
  end
end