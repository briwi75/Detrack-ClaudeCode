module TestDataHelper
  def self.load_sample_clients
    sample_file = File.join(File.dirname(__FILE__), '..', 'fixtures', 'sample_clients.json')
    data_loader = DeTrack::Services::DataLoader.new
    data_loader.load_clients_from_file(sample_file)
  end

  def self.clients_with_john
    load_sample_clients.select { |client| client.name_matches?('John') }
  end

  def self.clients_with_duplicate_emails
    detector = DeTrack::Services::DuplicateDetector.new(load_sample_clients)
    detector.find_duplicate_emails
  end

  def self.jane_smith_email_duplicates
    load_sample_clients.select { |client| client.email == 'jane.smith@yahoo.com' }
  end
end