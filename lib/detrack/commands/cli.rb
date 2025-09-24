require 'optparse'

module DeTrack
  module Commands
    class CLI
      def initialize(data_loader: Services::DataLoader.new)
        @data_loader = data_loader
        @clients = []
        @options = {}
      end

      def run(args)
        parse_arguments(args)
        load_clients
        execute_command
      rescue StandardError => e
        puts "Error: #{e.message}"
        false
      end

      private

      def parse_arguments(args)
        parser = create_option_parser

        begin
          parser.parse!(args)
        rescue OptionParser::InvalidOption, OptionParser::MissingArgument => e
          puts e.message
          puts
          puts parser.help
          exit(1)
        end

        validate_arguments
      end

      def create_option_parser
        OptionParser.new do |opts|
          opts.banner = "Usage: detrack [options]"
          opts.separator ""
          opts.separator "Commands:"

          opts.on('-s', '--search QUERY', 'Search clients by name (partial match)') do |query|
            @options[:command] = :search
            @options[:query] = query
          end

          opts.on('-d', '--duplicates', 'Find clients with duplicate email addresses') do
            @options[:command] = :duplicates
          end

          opts.on('-f', '--file FILE', 'Load data from local JSON file or URL') do |file|
            @options[:file] = file
          end

          opts.separator ""
          opts.separator "Options:"

          opts.on('-h', '--help', 'Show this help message') do
            puts opts
            exit
          end

          opts.on('--version', 'Show version') do
            puts "DeTrack Client Manager v1.0.0"
            exit
          end
        end
      end

      def validate_arguments
        if @options[:command].nil?
          puts "Error: Must specify a command (--search or --duplicates)"
          puts "Use --help for usage information"
          exit(1)
        end

        if @options[:command] == :search && (@options[:query].nil? || @options[:query].strip.empty?)
          puts "Error: Search query cannot be empty"
          exit(1)
        end
      end

      def load_clients
        if @options[:file]
          if url?(@options[:file])
            # Create a new data loader with the specified URL
            custom_loader = Services::DataLoader.new(url: @options[:file])
            print "Loading client data from URL: #{@options[:file]}..."
            @clients = custom_loader.load_clients
            puts " Done!"
            puts "Loaded #{@clients.length} clients"
          else
            @clients = @data_loader.load_clients_from_file(@options[:file])
            puts "Loaded #{@clients.length} clients from file: #{@options[:file]}"
          end
        else
          print "Loading client data from remote server..."
          @clients = @data_loader.load_clients
          puts " Done!"
          puts "Loaded #{@clients.length} clients"
        end
        puts
      end

      def url?(string)
        string.match?(/\Ahttps?:\/\//)
      end

      def execute_command
        case @options[:command]
        when :search
          SearchCommand.new(@clients).execute(@options[:query])
        when :duplicates
          DuplicatesCommand.new(@clients).execute
        else
          puts "Error: Unknown command"
          false
        end
      end
    end
  end
end