require 'spec_helper'

RSpec.describe DeTrack::Commands::CLI do
  let(:sample_clients) do
    [
      DeTrack::Models::Client.new(id: 1, full_name: 'John Doe', email: 'john.doe@example.com'),
      DeTrack::Models::Client.new(id: 2, full_name: 'Jane Smith', email: 'jane.smith@example.com')
    ]
  end

  let(:mock_data_loader) { double('DataLoader') }
  let(:cli) { described_class.new(data_loader: mock_data_loader) }

  before do
    allow(mock_data_loader).to receive(:load_clients).and_return(sample_clients)
    allow(mock_data_loader).to receive(:load_clients_from_file).and_return(sample_clients)
  end

  describe '#run' do
    context 'with search command' do
      it 'executes search successfully' do
        output = capture_stdout_stderr do
          result = cli.run(['--search', 'John'])
          expect(result).to be true
        end

        expect(output).to match(/Loading client data from remote server/)
        expect(output).to match(/Loaded 2 clients/)
        expect(output).to match(/Found 1 client\(s\) matching 'John'/)
      end

      it 'handles empty search query' do
        expect {
          cli.run(['--search', ''])
        }.to output(/Error: Search query cannot be empty/).to_stdout.and raise_error(SystemExit)
      end

      it 'handles missing search query' do
        expect {
          cli.run(['--search'])
        }.to output(/missing argument: --search/).to_stdout.and raise_error(SystemExit)
      end
    end

    context 'with duplicates command' do
      let(:clients_with_duplicates) do
        [
          DeTrack::Models::Client.new(id: 1, full_name: 'John Doe', email: 'john.doe@example.com'),
          DeTrack::Models::Client.new(id: 3, full_name: 'John Johnson', email: 'john.doe@example.com')
        ]
      end

      it 'executes duplicates command successfully' do
        allow(mock_data_loader).to receive(:load_clients).and_return(clients_with_duplicates)

        output = capture_stdout_stderr do
          result = cli.run(['--duplicates'])
          expect(result).to be true
        end

        expect(output).to match(/Loading client data from remote server/)
        expect(output).to match(/Loaded 2 clients/)
        expect(output).to match(/Found 1 email address\(es\) with duplicates/)
      end
    end

    context 'with file option' do
      it 'loads data from local file' do
        output = capture_stdout_stderr do
          result = cli.run(['--file', 'test.json', '--search', 'John'])
          expect(result).to be true
        end

        expect(output).to match(/Loaded 2 clients from file: test\.json/)
        expect(mock_data_loader).to have_received(:load_clients_from_file).with('test.json')
        expect(mock_data_loader).not_to have_received(:load_clients)
      end
    end

    context 'with help option' do
      it 'displays help and exits' do
        expect {
          cli.run(['--help'])
        }.to output(/Usage: detrack \[options\]/).to_stdout.and raise_error(SystemExit)
      end
    end

    context 'with version option' do
      it 'displays version and exits' do
        expect {
          cli.run(['--version'])
        }.to output(/DeTrack Client Manager v1\.0\.0/).to_stdout.and raise_error(SystemExit)
      end
    end

    context 'with invalid options' do
      it 'handles invalid option gracefully' do
        expect {
          cli.run(['--invalid'])
        }.to output(/invalid option: --invalid/).to_stdout.and raise_error(SystemExit)
      end
    end

    context 'with no command specified' do
      it 'displays error and exits' do
        expect {
          cli.run([])
        }.to output(/Error: Must specify a command/).to_stdout.and raise_error(SystemExit)
      end
    end

    context 'with data loading errors' do
      it 'handles network errors gracefully' do
        allow(mock_data_loader).to receive(:load_clients)
          .and_raise(DeTrack::Services::DataLoader::NetworkError.new('Connection failed'))

        output = capture_stdout_stderr do
          result = cli.run(['--search', 'John'])
          expect(result).to be false
        end

        expect(output).to match(/Error: Connection failed/)
      end

      it 'handles parse errors gracefully' do
        allow(mock_data_loader).to receive(:load_clients)
          .and_raise(DeTrack::Services::DataLoader::ParseError.new('Invalid JSON'))

        output = capture_stdout_stderr do
          result = cli.run(['--search', 'John'])
          expect(result).to be false
        end

        expect(output).to match(/Error: Invalid JSON/)
      end

      it 'handles file loading errors gracefully' do
        allow(mock_data_loader).to receive(:load_clients_from_file)
          .and_raise(DeTrack::Services::DataLoader::LoadError.new('File not found'))

        output = capture_stdout_stderr do
          result = cli.run(['--file', 'missing.json', '--search', 'John'])
          expect(result).to be false
        end

        expect(output).to match(/Error: File not found/)
      end
    end

    context 'with unexpected errors' do
      it 'handles generic errors gracefully' do
        allow(mock_data_loader).to receive(:load_clients)
          .and_raise(StandardError.new('Unexpected error'))

        output = capture_stdout_stderr do
          result = cli.run(['--search', 'John'])
          expect(result).to be false
        end

        expect(output).to match(/Error: Unexpected error/)
      end
    end
  end

  private

  def capture_stdout_stderr
    original_stdout = $stdout
    original_stderr = $stderr
    $stdout = StringIO.new
    $stderr = StringIO.new

    begin
      yield
      return $stdout.string + $stderr.string
    rescue SystemExit
      raise
    ensure
      $stdout = original_stdout
      $stderr = original_stderr
    end
  end
end