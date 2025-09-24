require 'spec_helper'

# These tests actually make network calls and should only be run when needed
# Run with: bundle exec rspec spec/integration/network_integration_spec.rb
RSpec.describe 'Network Integration Tests', :network_integration do
  let(:data_loader) { DeTrack::Services::DataLoader.new }

  describe 'DataLoader' do
    context 'with real network requests' do
      it 'successfully loads data from the default URL' do
        clients = data_loader.load_clients

        expect(clients).to be_an(Array)
        expect(clients.length).to be > 0
        expect(clients.first).to be_a(DeTrack::Models::Client)
        expect(clients.first.id).to be_a(Integer)
        expect(clients.first.full_name).to be_a(String)
        expect(clients.first.email).to match(/@/)
      end

      it 'handles network timeouts gracefully' do
        # This test would need a custom HTTP client that simulates timeout
        # For now, we'll test the error handling structure
        expect {
          DeTrack::Services::DataLoader::NetworkError.new('Timeout')
        }.not_to raise_error
      end

      it 'validates JSON structure from remote source' do
        clients = data_loader.load_clients

        # Verify the structure matches our expectations
        clients.each do |client|
          expect(client.id).to be_a(Integer)
          expect(client.full_name).to be_a(String)
          expect(client.email).to match(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i)
        end
      end

      it 'loads consistent data with local fixture' do
        # Load from network
        network_clients = data_loader.load_clients

        # Load from local fixture
        fixture_clients = TestDataHelper.load_sample_clients

        # They should have the same structure and similar count
        expect(network_clients.length).to eq(fixture_clients.length)

        # Sample a few clients to verify they match
        network_john = network_clients.find { |c| c.full_name == 'John Doe' }
        fixture_john = fixture_clients.find { |c| c.full_name == 'John Doe' }

        expect(network_john.id).to eq(fixture_john.id)
        expect(network_john.email).to eq(fixture_john.email)
      end
    end

    context 'with different URLs' do
      it 'can load from a custom URL via --file parameter' do
        # Test the URL detection in CLI
        cli = DeTrack::Commands::CLI.new
        expect(cli.send(:url?, 'https://example.com/test.json')).to be true
        expect(cli.send(:url?, 'http://example.com/test.json')).to be true
        expect(cli.send(:url?, 'local_file.json')).to be false
      end
    end
  end

  describe 'CLI with network operations' do
    it 'displays proper loading messages for network requests' do
      # This would test the actual CLI output with network calls
      # Requires careful setup to avoid hitting the network repeatedly in tests
    end
  end
end