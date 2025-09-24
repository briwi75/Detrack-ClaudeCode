require 'spec_helper'

RSpec.describe DeTrack::Models::Client do
  describe '#initialize' do
    it 'creates a client with valid attributes' do
      client = described_class.new(
        id: 1,
        full_name: 'John Doe',
        email: 'john.doe@example.com'
      )

      expect(client.id).to eq(1)
      expect(client.full_name).to eq('John Doe')
      expect(client.email).to eq('john.doe@example.com')
    end

    it 'normalizes email to lowercase' do
      client = described_class.new(
        id: 1,
        full_name: 'John Doe',
        email: 'John.Doe@EXAMPLE.COM'
      )

      expect(client.email).to eq('john.doe@example.com')
    end

    it 'strips whitespace from full_name and email' do
      client = described_class.new(
        id: 1,
        full_name: '  John Doe  ',
        email: '  john.doe@example.com  '
      )

      expect(client.full_name).to eq('John Doe')
      expect(client.email).to eq('john.doe@example.com')
    end

    context 'with invalid id' do
      it 'raises ArgumentError for negative id' do
        expect {
          described_class.new(id: -1, full_name: 'John', email: 'john@example.com')
        }.to raise_error(ArgumentError, 'ID must be a positive integer')
      end

      it 'raises ArgumentError for zero id' do
        expect {
          described_class.new(id: 0, full_name: 'John', email: 'john@example.com')
        }.to raise_error(ArgumentError, 'ID must be a positive integer')
      end

      it 'raises ArgumentError for non-integer id' do
        expect {
          described_class.new(id: '1', full_name: 'John', email: 'john@example.com')
        }.to raise_error(ArgumentError, 'ID must be a positive integer')
      end
    end

    context 'with invalid full_name' do
      it 'raises ArgumentError for nil name' do
        expect {
          described_class.new(id: 1, full_name: nil, email: 'john@example.com')
        }.to raise_error(ArgumentError, 'Full name cannot be nil or empty')
      end

      it 'raises ArgumentError for empty name' do
        expect {
          described_class.new(id: 1, full_name: '', email: 'john@example.com')
        }.to raise_error(ArgumentError, 'Full name cannot be nil or empty')
      end

      it 'raises ArgumentError for whitespace-only name' do
        expect {
          described_class.new(id: 1, full_name: '   ', email: 'john@example.com')
        }.to raise_error(ArgumentError, 'Full name cannot be nil or empty')
      end
    end

    context 'with invalid email' do
      it 'raises ArgumentError for nil email' do
        expect {
          described_class.new(id: 1, full_name: 'John', email: nil)
        }.to raise_error(ArgumentError, 'Email cannot be nil or empty')
      end

      it 'raises ArgumentError for empty email' do
        expect {
          described_class.new(id: 1, full_name: 'John', email: '')
        }.to raise_error(ArgumentError, 'Email cannot be nil or empty')
      end

      it 'raises ArgumentError for invalid email format' do
        expect {
          described_class.new(id: 1, full_name: 'John', email: 'invalid-email')
        }.to raise_error(ArgumentError, 'Invalid email format')
      end
    end
  end

  describe '.from_hash' do
    it 'creates a client from hash' do
      hash = {
        'id' => 1,
        'full_name' => 'John Doe',
        'email' => 'john.doe@example.com'
      }

      client = described_class.from_hash(hash)

      expect(client.id).to eq(1)
      expect(client.full_name).to eq('John Doe')
      expect(client.email).to eq('john.doe@example.com')
    end
  end

  describe '#to_h' do
    it 'converts client to hash' do
      client = described_class.new(
        id: 1,
        full_name: 'John Doe',
        email: 'john.doe@example.com'
      )

      hash = client.to_h

      expect(hash).to eq({
        'id' => 1,
        'full_name' => 'John Doe',
        'email' => 'john.doe@example.com'
      })
    end
  end

  describe '#name_matches?' do
    let(:client) do
      described_class.new(
        id: 1,
        full_name: 'John Doe',
        email: 'john.doe@example.com'
      )
    end

    it 'matches partial name (case insensitive)' do
      expect(client.name_matches?('john')).to be true
      expect(client.name_matches?('JOHN')).to be true
      expect(client.name_matches?('doe')).to be true
      expect(client.name_matches?('John Doe')).to be true
    end

    it 'does not match non-matching strings' do
      expect(client.name_matches?('jane')).to be false
      expect(client.name_matches?('smith')).to be false
    end

    it 'handles edge cases' do
      expect(client.name_matches?(nil)).to be false
      expect(client.name_matches?('')).to be false
      expect(client.name_matches?('   ')).to be false
    end

    it 'strips whitespace from query' do
      expect(client.name_matches?('  john  ')).to be true
    end
  end

  describe '#==' do
    let(:client1) do
      described_class.new(id: 1, full_name: 'John', email: 'john@example.com')
    end
    let(:client2) do
      described_class.new(id: 1, full_name: 'John', email: 'john@example.com')
    end
    let(:client3) do
      described_class.new(id: 2, full_name: 'John', email: 'john@example.com')
    end

    it 'returns true for identical clients' do
      expect(client1).to eq(client2)
    end

    it 'returns false for different clients' do
      expect(client1).not_to eq(client3)
    end

    it 'returns false for non-client objects' do
      expect(client1).not_to eq('not a client')
    end
  end

  describe '#to_s' do
    it 'returns formatted string representation' do
      client = described_class.new(
        id: 1,
        full_name: 'John Doe',
        email: 'john.doe@example.com'
      )

      expect(client.to_s).to eq('ID: 1, Name: John Doe, Email: john.doe@example.com')
    end
  end
end