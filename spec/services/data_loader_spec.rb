require 'spec_helper'

RSpec.describe DeTrack::Services::DataLoader do
  let(:valid_json) do
    '[{"id": 1, "full_name": "John Doe", "email": "john@example.com"}]'
  end

  let(:sample_file_path) do
    File.join(File.dirname(__FILE__), '..', 'fixtures', 'sample_clients.json')
  end

  describe '#load_clients' do
    let(:mock_http) { double('Net::HTTP') }
    let(:success_response) { double('Net::HTTPSuccess', is_a?: true, body: valid_json) }
    let(:data_loader) { described_class.new(http_client: mock_http) }

    before do
      allow(mock_http).to receive(:get_response).and_return(success_response)
      allow(success_response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(true)
    end

    it 'loads clients from remote URL' do
      clients = data_loader.load_clients

      expect(clients).to be_an(Array)
      expect(clients.length).to eq(1)
      expect(clients.first).to be_a(DeTrack::Models::Client)
      expect(clients.first.id).to eq(1)
      expect(clients.first.full_name).to eq('John Doe')
    end

    context 'with network errors' do
      it 'raises NetworkError for timeout' do
        allow(mock_http).to receive(:get_response).and_raise(Timeout::Error)

        expect {
          data_loader.load_clients
        }.to raise_error(DeTrack::Services::DataLoader::NetworkError, /Failed to fetch data/)
      end

      it 'raises NetworkError for HTTP errors' do
        error_response = double('Net::HTTPError', is_a?: false, code: '404', message: 'Not Found')
        allow(mock_http).to receive(:get_response).and_return(error_response)
        allow(error_response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(false)

        expect {
          data_loader.load_clients
        }.to raise_error(DeTrack::Services::DataLoader::NetworkError, /HTTP 404: Not Found/)
      end

      it 'raises NetworkError for socket errors' do
        allow(mock_http).to receive(:get_response).and_raise(SocketError.new('Host not found'))

        expect {
          data_loader.load_clients
        }.to raise_error(DeTrack::Services::DataLoader::NetworkError, /Failed to fetch data.*Host not found/)
      end
    end

    context 'with invalid JSON' do
      it 'raises ParseError for malformed JSON' do
        bad_response = double('Net::HTTPSuccess', is_a?: true, body: 'invalid json')
        allow(mock_http).to receive(:get_response).and_return(bad_response)
        allow(bad_response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(true)

        expect {
          data_loader.load_clients
        }.to raise_error(DeTrack::Services::DataLoader::ParseError, /Failed to parse JSON data/)
      end

      it 'raises ParseError for non-array JSON' do
        object_response = double('Net::HTTPSuccess', is_a?: true, body: '{"not": "array"}')
        allow(mock_http).to receive(:get_response).and_return(object_response)
        allow(object_response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(true)

        expect {
          data_loader.load_clients
        }.to raise_error(DeTrack::Services::DataLoader::ParseError, /Expected JSON array/)
      end
    end

    context 'with invalid client data' do
      it 'raises ParseError for missing required fields' do
        incomplete_json = '[{"id": 1, "full_name": "John"}]'
        incomplete_response = double('Net::HTTPSuccess', is_a?: true, body: incomplete_json)
        allow(mock_http).to receive(:get_response).and_return(incomplete_response)
        allow(incomplete_response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(true)

        expect {
          data_loader.load_clients
        }.to raise_error(DeTrack::Services::DataLoader::ParseError, /Missing required fields.*email/)
      end

      it 'raises ParseError for invalid client attributes' do
        invalid_json = '[{"id": -1, "full_name": "John", "email": "john@example.com"}]'
        invalid_response = double('Net::HTTPSuccess', is_a?: true, body: invalid_json)
        allow(mock_http).to receive(:get_response).and_return(invalid_response)
        allow(invalid_response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(true)

        expect {
          data_loader.load_clients
        }.to raise_error(DeTrack::Services::DataLoader::ParseError, /Invalid client data.*ID must be a positive integer/)
      end

      it 'raises ParseError for non-hash client data' do
        string_json = '["not an object"]'
        string_response = double('Net::HTTPSuccess', is_a?: true, body: string_json)
        allow(mock_http).to receive(:get_response).and_return(string_response)
        allow(string_response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(true)

        expect {
          data_loader.load_clients
        }.to raise_error(DeTrack::Services::DataLoader::ParseError, /Expected hash for client/)
      end
    end
  end

  describe '#load_clients_from_file' do
    it 'loads clients from local file' do
      data_loader = described_class.new

      clients = data_loader.load_clients_from_file(sample_file_path)

      expect(clients).to be_an(Array)
      expect(clients.length).to eq(35)
      expect(clients.first).to be_a(DeTrack::Models::Client)
    end

    it 'raises LoadError for non-existent file' do
      data_loader = described_class.new

      expect {
        data_loader.load_clients_from_file('/non/existent/file.json')
      }.to raise_error(DeTrack::Services::DataLoader::LoadError, /File not found/)
    end

    it 'raises ParseError for invalid JSON file' do
      temp_file = '/tmp/invalid.json'
      File.write(temp_file, 'invalid json')

      data_loader = described_class.new

      expect {
        data_loader.load_clients_from_file(temp_file)
      }.to raise_error(DeTrack::Services::DataLoader::ParseError, /Failed to parse JSON file/)

      File.delete(temp_file) if File.exist?(temp_file)
    end
  end
end