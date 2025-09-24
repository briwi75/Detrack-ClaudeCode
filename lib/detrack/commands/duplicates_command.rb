module DeTrack
  module Commands
    class DuplicatesCommand
      def initialize(clients)
        @detector = Services::DuplicateDetector.new(clients)
      end

      def execute
        duplicates = @detector.find_duplicate_emails

        if duplicates.empty?
          puts "No duplicate email addresses found."
        else
          puts "Found #{duplicates.length} email address(es) with duplicates:"
          puts

          duplicates.each do |email, clients|
            puts "Email: #{email} (#{clients.length} clients)"
            clients.each do |client|
              puts "  #{client.to_s}"
            end
            puts
          end

          total_duplicates = @detector.duplicate_count
          puts "Total clients with duplicate emails: #{total_duplicates}"
        end

        true
      end

      private

      attr_reader :detector
    end
  end
end