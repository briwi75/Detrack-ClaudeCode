module DeTrack
  module Services
    class DuplicateDetector
      def initialize(clients)
        @clients = clients || []
      end

      def find_duplicate_emails
        email_groups = group_by_email
        duplicates = email_groups.select { |_, clients| clients.length > 1 }

        duplicates.transform_values { |clients| sort_clients_by_id(clients) }
      end

      def has_duplicates?
        !find_duplicate_emails.empty?
      end

      def duplicate_count
        find_duplicate_emails.sum { |_, clients| clients.length }
      end

      def unique_duplicate_emails
        find_duplicate_emails.keys
      end

      def find_duplicates_for_email(email)
        return [] if email.nil? || email.strip.empty?

        normalized_email = email.strip.downcase
        @clients.select { |client| client.email == normalized_email }
      end

      private

      def group_by_email
        @clients.group_by(&:email)
      end

      def sort_clients_by_id(clients)
        clients.sort_by(&:id)
      end
    end
  end
end