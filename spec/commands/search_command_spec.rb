require 'spec_helper'

RSpec.describe DeTrack::Commands::SearchCommand do
  let(:clients) { TestDataHelper.load_sample_clients }
  let(:command) { described_class.new(clients) }

  describe '#execute' do
    context 'with valid query' do
      it 'displays matching clients' do
        expect { command.execute('John') }.to output(
          /Found 2 client\(s\) matching 'John':\s*\n\s*\nID: 1, Name: John Doe, Email: john\.doe@gmail\.com\nID: 3, Name: Alex Johnson, Email: alex\.johnson@hotmail\.com\n/
        ).to_stdout
      end

      it 'returns true on successful search' do
        expect(command.execute('John')).to be true
      end
    end

    context 'with no matches' do
      it 'displays no matches message' do
        expect { command.execute('Nonexistent') }.to output(
          "No clients found matching 'Nonexistent'\n"
        ).to_stdout
      end

      it 'returns true even when no matches found' do
        expect(command.execute('Nonexistent')).to be true
      end
    end

    context 'with empty or nil query' do
      it 'displays error for nil query' do
        expect { command.execute(nil) }.to output(
          "Error: Search query cannot be empty\n"
        ).to_stdout
      end

      it 'displays error for empty query' do
        expect { command.execute('') }.to output(
          "Error: Search query cannot be empty\n"
        ).to_stdout
      end

      it 'displays error for whitespace-only query' do
        expect { command.execute('   ') }.to output(
          "Error: Search query cannot be empty\n"
        ).to_stdout
      end

      it 'returns false for invalid queries' do
        expect(command.execute(nil)).to be false
        expect(command.execute('')).to be false
        expect(command.execute('   ')).to be false
      end
    end

    context 'with case-insensitive search' do
      it 'finds matches regardless of case' do
        expect { command.execute('JANE') }.to output(
          /Found 2 client\(s\) matching 'JANE':\s*\n\s*\nID: 2, Name: Jane Smith, Email: jane\.smith@yahoo\.com\nID: 15, Name: Another Jane Smith, Email: jane\.smith@yahoo\.com\n/
        ).to_stdout
      end

      it 'returns identical output for different case variations of same query' do
        # Test that 'John', 'john', and 'JOHN' produce identical output
        output_mixed = capture_stdout { command.execute('John') }
        output_lower = capture_stdout { command.execute('john') }
        output_upper = capture_stdout { command.execute('JOHN') }

        # All outputs should be identical except for the query string in the message
        expect(output_mixed).to include('Found 2 client(s) matching \'John\'')
        expect(output_lower).to include('Found 2 client(s) matching \'john\'')
        expect(output_upper).to include('Found 2 client(s) matching \'JOHN\'')

        # The actual results should be identical (same client lists)
        expect(output_mixed).to include('ID: 1, Name: John Doe, Email: john.doe@gmail.com')
        expect(output_mixed).to include('ID: 3, Name: Alex Johnson, Email: alex.johnson@hotmail.com')

        expect(output_lower).to include('ID: 1, Name: John Doe, Email: john.doe@gmail.com')
        expect(output_lower).to include('ID: 3, Name: Alex Johnson, Email: alex.johnson@hotmail.com')

        expect(output_upper).to include('ID: 1, Name: John Doe, Email: john.doe@gmail.com')
        expect(output_upper).to include('ID: 3, Name: Alex Johnson, Email: alex.johnson@hotmail.com')
      end
    end

    private

    def capture_stdout
      original_stdout = $stdout
      $stdout = StringIO.new
      yield
      $stdout.string
    ensure
      $stdout = original_stdout
    end

    context 'with partial name matching' do
      it 'finds clients with partial matches' do
        expect { command.execute('Sebastian') }.to output(
          /Found 1 client\(s\) matching 'Sebastian':\s*\n\s*\nID: 22, Name: Sebastian Allen, Email: sebastian\.allen@hotmail\.com\n/
        ).to_stdout
      end
    end
  end
end