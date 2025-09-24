require 'json'
require 'net/http'
require 'uri'

module DeTrack
  module Services
    class DataLoader
      DEFAULT_URL = 'https://appassets02.shiftcare.com/manual/clients.json'

      class LoadError < StandardError; end
      class NetworkError < LoadError; end
      class ParseError < LoadError; end

      def initialize(url: DEFAULT_URL, http_client: Net::HTTP)
        @url = url
        @http_client = http_client
      end

      def load_clients
        json_data = fetch_data
        parse_clients(json_data)
      rescue Timeout::Error, Net::HTTPError, SocketError => e
        raise NetworkError, "Failed to fetch data from #{@url}: #{e.message}"
      rescue JSON::ParserError => e
        raise ParseError, "Failed to parse JSON data: #{e.message}"
      end

      def load_clients_from_file(file_path)
        raise LoadError, "File not found: #{file_path}" unless File.exist?(file_path)

        json_data = File.read(file_path)
        parse_clients(json_data)
      rescue Errno::ENOENT => e
        raise LoadError, "File not found: #{e.message}"
      rescue Errno::EACCES => e
        raise LoadError, "Permission denied: #{e.message}"
      rescue JSON::ParserError => e
        raise ParseError, "Failed to parse JSON file: #{e.message}"
      end

      private

      def fetch_data
        uri = URI(@url)
        response = @http_client.get_response(uri)

        unless response.is_a?(Net::HTTPSuccess)
          raise NetworkError, "HTTP #{response.code}: #{response.message}"
        end

        response.body
      end

      def parse_clients(json_data)
        parsed_data = JSON.parse(json_data)

        unless parsed_data.is_a?(Array)
          raise ParseError, 'Expected JSON array of client objects'
        end

        parsed_data.map.with_index do |client_hash, index|
          validate_client_data(client_hash, index)
          Models::Client.from_hash(client_hash)
        rescue ArgumentError => e
          raise ParseError, "Invalid client data at index #{index}: #{e.message}"
        end
      end

      def validate_client_data(client_hash, index)
        unless client_hash.is_a?(Hash)
          raise ParseError, "Expected hash for client at index #{index}"
        end

        required_fields = %w[id full_name email]
        missing_fields = required_fields - client_hash.keys

        unless missing_fields.empty?
          raise ParseError, "Missing required fields at index #{index}: #{missing_fields.join(', ')}"
        end
      end
    end
  end
end