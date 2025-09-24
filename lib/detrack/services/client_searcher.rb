module DeTrack
  module Services
    class ClientSearcher
      def initialize(clients)
        @clients = clients || []
      end

      def search_by_name(query)
        return [] if query.nil? || query.strip.empty?

        @clients.select { |client| client.name_matches?(query) }
      end

      def search_by_exact_name(query)
        return [] if query.nil? || query.strip.empty?

        normalized_query = query.strip.downcase
        @clients.select { |client| client.full_name.downcase == normalized_query }
      end

      def search_by_id(id)
        return nil unless id.is_a?(Integer) && id > 0

        @clients.find { |client| client.id == id }
      end

      def search_by_email(email)
        return [] if email.nil? || email.strip.empty?

        normalized_email = email.strip.downcase
        @clients.select { |client| client.email == normalized_email }
      end

      def count
        @clients.length
      end

      def empty?
        @clients.empty?
      end
    end
  end
end