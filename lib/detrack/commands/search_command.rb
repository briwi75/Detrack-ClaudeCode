module DeTrack
  module Commands
    class SearchCommand
      def initialize(clients)
        @searcher = Services::ClientSearcher.new(clients)
      end

      def execute(query)
        if query.nil? || query.strip.empty?
          puts "Error: Search query cannot be empty"
          return false
        end

        results = @searcher.search_by_name(query)

        if results.empty?
          puts "No clients found matching '#{query}'"
        else
          puts "Found #{results.length} client(s) matching '#{query}':"
          puts
          results.each do |client|
            puts client.to_s
          end
        end

        true
      end

      private

      attr_reader :searcher
    end
  end
end