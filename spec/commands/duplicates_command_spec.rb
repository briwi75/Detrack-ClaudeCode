require 'spec_helper'

RSpec.describe DeTrack::Commands::DuplicatesCommand do
  let(:clients_with_duplicates) { TestDataHelper.load_sample_clients }

  let(:clients_without_duplicates) do
    [
      DeTrack::Models::Client.new(id: 1, full_name: 'John Doe', email: 'john.doe@example.com'),
      DeTrack::Models::Client.new(id: 2, full_name: 'Jane Smith', email: 'jane.smith@example.com'),
      DeTrack::Models::Client.new(id: 3, full_name: 'Bob Wilson', email: 'bob.wilson@test.com')
    ]
  end

  describe '#execute' do
    context 'with duplicate emails' do
      let(:command) { described_class.new(clients_with_duplicates) }

      it 'displays all duplicate groups' do
        output = capture_stdout { command.execute }

        expect(output).to match(/Found 1 email address\(es\) with duplicates:/)
        expect(output).to match(/Email: jane\.smith@yahoo\.com \(2 clients\)/)
        expect(output).to match(/Total clients with duplicate emails: 2/)
      end

      it 'displays clients in sorted order by ID' do
        output = capture_stdout { command.execute }

        expect(output).to match(/ID: 2, Name: Jane Smith, Email: jane\.smith@yahoo\.com/)
        expect(output).to match(/ID: 15, Name: Another Jane Smith, Email: jane\.smith@yahoo\.com/)

        # Verify that ID 2 appears before ID 15 in the output
        id2_position = output.index('ID: 2, Name: Jane Smith')
        id15_position = output.index('ID: 15, Name: Another Jane Smith')
        expect(id2_position).to be < id15_position
      end

      it 'returns true' do
        expect(command.execute).to be true
      end
    end

    context 'without duplicate emails' do
      let(:command) { described_class.new(clients_without_duplicates) }

      it 'displays no duplicates message' do
        output = capture_stdout { command.execute }

        expect(output.strip).to eq('No duplicate email addresses found.')
      end

      it 'returns true' do
        expect(command.execute).to be true
      end
    end

    context 'with empty client list' do
      let(:command) { described_class.new([]) }

      it 'displays no duplicates message' do
        output = capture_stdout { command.execute }

        expect(output.strip).to eq('No duplicate email addresses found.')
      end

      it 'returns true' do
        expect(command.execute).to be true
      end
    end

    context 'with nil client list' do
      let(:command) { described_class.new(nil) }

      it 'displays no duplicates message' do
        output = capture_stdout { command.execute }

        expect(output.strip).to eq('No duplicate email addresses found.')
      end

      it 'returns true' do
        expect(command.execute).to be true
      end
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
end