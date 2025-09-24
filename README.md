# DeTrack Client Manager

A Ruby command-line application for managing and searching client data from a remote JSON dataset.

## Features

- **Client Search**: Find clients by partial name matching (case-insensitive)
- **Duplicate Detection**: Identify clients with the same email address
- **Flexible Data Loading**: Load data from remote URL or local JSON file
- **Robust Error Handling**: Comprehensive error handling for network issues, invalid data, and edge cases
- **Thoroughly Tested**: Manual testing with comprehensive test specifications for edge cases and negative scenarios

## Installation

### Prerequisites

- **Ruby 3.4.6** (latest stable version)
- **Bundler gem** (for dependency management)

### Ruby Installation

If you don't have Ruby 3.4.6 installed, you can install it using:

#### Using rbenv (recommended):
```bash
rbenv install 3.4.6
rbenv global 3.4.6
```

#### Using RVM:
```bash
rvm install 3.4.6
rvm use 3.4.6 --default
```

#### Using system package manager (macOS with Homebrew):
```bash
brew install ruby@3.4
```

### Setup

1. Clone or extract the project:
   ```bash
   cd DeTrack-Test-ClaudeCode
   ```

2. Install dependencies:
   ```bash
   bundle install
   ```

3. Make the executable file executable (if needed):
   ```bash
   chmod +x bin/detrack
   ```

4. Verify your setup (optional):
   ```bash
   ruby verify_setup.rb
   ```

**Note**: The application will automatically check for Ruby 3.4.6+ and display an error if an older version is detected.

## Usage

### Basic Commands

#### Search for clients by name
```bash
./bin/detrack --search "John"
./bin/detrack -s "Smith"
```

#### Find clients with duplicate email addresses
```bash
./bin/detrack --duplicates
./bin/detrack -d
```

#### Load data from a local JSON file or URL
```bash
./bin/detrack --file path/to/clients.json --search "Jane"
./bin/detrack -f data.json --duplicates
./bin/detrack --file https://example.com/clients.json --search "Jane"
```

### Command Line Options

- `-s, --search QUERY`: Search clients by name (partial match, case-insensitive)
- `-d, --duplicates`: Find clients with duplicate email addresses
- `-f, --file FILE`: Load data from local JSON file or URL
- `-h, --help`: Show help message
- `--version`: Show version information

### Examples

1. **Search for clients named "John":**
   ```bash
   ./bin/detrack --search "John"
   ```
   Output:
   ```
   Loading client data from remote server... Done!
   Loaded 35 clients

   Found 2 client(s) matching 'John':

   ID: 1, Name: John Doe, Email: john.doe@gmail.com
   ID: 3, Name: Alex Johnson, Email: alex.johnson@hotmail.com
   ```

2. **Find duplicate email addresses:**
   ```bash
   ./bin/detrack --duplicates
   ```
   Output:
   ```
   Loading client data from remote server... Done!
   Loaded 35 clients

   Found 1 email address(es) with duplicates:

   Email: jane.smith@yahoo.com (2 clients)
     ID: 2, Name: Jane Smith, Email: jane.smith@yahoo.com
     ID: 15, Name: Another Jane Smith, Email: jane.smith@yahoo.com

   Total clients with duplicate emails: 2
   ```

3. **Load from local file:**
   ```bash
   ./bin/detrack --file ./spec/fixtures/sample_clients.json --search "Johnson"
   ```

4. **Load from custom URL:**
   ```bash
   ./bin/detrack --file https://appassets02.shiftcare.com/manual/clients.json --search "Jane"
   ```

## Architecture

### Project Structure

```
DeTrack-Test-ClaudeCode/
├── bin/
│   └── detrack                    # Executable entry point
├── lib/
│   ├── detrack.rb                # Main module loader
│   └── detrack/
│       ├── models/
│       │   └── client.rb         # Client data model
│       ├── services/
│       │   ├── data_loader.rb    # Remote/local data loading
│       │   ├── client_searcher.rb # Search functionality
│       │   └── duplicate_detector.rb # Duplicate detection
│       └── commands/
│           ├── cli.rb            # Command-line interface
│           ├── search_command.rb # Search command implementation
│           └── duplicates_command.rb # Duplicates command implementation
├── spec/                         # Test suite
├── Gemfile                       # Dependencies
└── README.md                     # This file
```

### Design Principles

- **Single Responsibility Principle**: Each class has a single, well-defined responsibility
- **Open/Closed Principle**: Easy to extend with new commands and functionality
- **Dependency Injection**: Classes accept dependencies, making them testable
- **Error Handling**: Comprehensive error handling with custom exception types
- **Separation of Concerns**: Clear separation between data access, business logic, and presentation

### Key Components

1. **Client Model** (`DeTrack::Models::Client`): Represents a single client with validation
2. **Data Loader** (`DeTrack::Services::DataLoader`): Handles loading data from remote URLs or local files
3. **Client Searcher** (`DeTrack::Services::ClientSearcher`): Provides various search capabilities
4. **Duplicate Detector** (`DeTrack::Services::DuplicateDetector`): Identifies duplicate email addresses
5. **Commands**: Encapsulate user operations (search, duplicates)
6. **CLI**: Parses command-line arguments and coordinates operations

## Testing

### Test Suite

The project includes a comprehensive RSpec test suite with:

- **Unit Tests**: For all models, services, and commands
- **Integration Tests**: For CLI functionality
- **Edge Cases**: Empty inputs, nil values, invalid data
- **Error Scenarios**: Network failures, invalid JSON, missing files
- **Negative Testing**: Invalid inputs, malformed data

### Test Files Structure

```
spec/
├── models/client_spec.rb
├── services/
│   ├── data_loader_spec.rb
│   ├── client_searcher_spec.rb
│   └── duplicate_detector_spec.rb
├── commands/
│   ├── cli_spec.rb
│   ├── search_command_spec.rb
│   └── duplicates_command_spec.rb
├── integration/
│   └── network_integration_spec.rb
├── support/
│   └── test_data_helper.rb
└── fixtures/sample_clients.json (real-world data copy)
```

### Running Tests

With Ruby 3.4.6 and dependencies installed:

```bash
# Using the test runner script (recommended):
ruby run_tests.rb --unit          # Run unit tests only (fast, offline)
ruby run_tests.rb --integration   # Run network integration tests only
ruby run_tests.rb --all           # Run all tests (default)
ruby run_tests.rb -f documentation # Run with verbose output
ruby run_tests.rb -c              # Generate coverage report

# Using RSpec directly:
bundle exec rspec --exclude-pattern="spec/integration/*"  # Unit tests only
bundle exec rspec spec/integration/                       # Integration tests only
bundle exec rspec                                         # All tests

# Run specific test files
bundle exec rspec spec/models/client_spec.rb
bundle exec rspec spec/services/
```

**Test Data**: All unit tests now use real-world data from the actual JSON API, ensuring tests reflect realistic scenarios. The `sample_clients.json` fixture contains an exact copy of the remote data, allowing tests to run offline while maintaining data integrity.

### Code Coverage

The project uses [SimpleCov](https://github.com/simplecov-ruby/simplecov) for code coverage analysis:

```bash
# Run tests with coverage report
bundle exec rspec

# Or use the coverage check script
ruby check_coverage.rb

# View coverage report (opens in browser)
open coverage/index.html
```

**Coverage Configuration**:
- **Minimum threshold**: 90% coverage required
- **Reports generated**: HTML (detailed) + console summary
- **Grouped by**: Models, Services, Commands for easy analysis
- **Filtered**: Test files and vendor dependencies excluded

The coverage report shows:
- **Line coverage**: Percentage of code lines executed
- **Branch coverage**: Conditional logic paths tested
- **File-by-file breakdown**: Detailed coverage per module
- **Missing lines**: Specific untested code highlighted

### Manual Testing

The application has also been thoroughly tested manually:
- All command-line options and combinations
- Error handling scenarios
- Remote and local data loading
- Edge cases and invalid inputs

## Assumptions and Decisions

### Data Format Assumptions
- JSON data is an array of client objects
- Each client has `id` (integer), `full_name` (string), and `email` (string) fields
- Email addresses are case-insensitive for comparison
- IDs are positive integers

### Search Behavior
- Name search is case-insensitive and supports partial matching
- Email comparison is case-insensitive
- Whitespace is trimmed from inputs
- Empty or whitespace-only queries return no results

### Error Handling
- Ruby version compatibility is checked at startup
- Network timeouts and HTTP errors are gracefully handled
- Invalid JSON structure raises descriptive errors
- Missing or invalid client data is reported with specific error messages
- File access errors (permissions, not found) are handled appropriately

### Performance Considerations
- Data is loaded once per command execution
- In-memory operations for searching and duplicate detection
- Sorted results for duplicate detection (by client ID)

## Known Limitations

### Current Limitations

1. **Memory Usage**: All client data is loaded into memory at once
   - Impact: Large datasets could cause memory issues
   - Mitigation: Currently acceptable for expected dataset sizes

2. **Network Resilience**: No retry logic for failed network requests
   - Impact: Single network failures cause complete operation failure
   - Mitigation: Users can retry manually or use local files

3. **Search Capabilities**: Only supports partial name matching
   - Impact: No advanced search features (regex, multiple criteria, field-specific search)
   - Mitigation: Current functionality meets specified requirements

4. **Output Format**: Fixed console output format
   - Impact: No support for different output formats (JSON, CSV, XML)
   - Mitigation: Human-readable format is appropriate for CLI tool

5. **Concurrent Access**: No support for concurrent operations
   - Impact: Cannot run multiple operations simultaneously
   - Mitigation: Not required for current use case

### Data Quality Assumptions

1. **Email Validation**: Basic regex validation only
   - Impact: May accept some technically invalid email addresses
   - Mitigation: Follows common email validation patterns

2. **Duplicate Definition**: Only email-based duplicate detection
   - Impact: Does not detect duplicates based on name similarity or other criteria
   - Mitigation: Email is the most reliable unique identifier

3. **Character Encoding**: Assumes UTF-8 encoding
   - Impact: May not handle other character encodings properly
   - Mitigation: UTF-8 is standard for JSON data

## Future Improvements

Areas identified for potential enhancement:

### Performance Optimizations
- Database integration for large datasets
- Streaming JSON parsing for very large files
- Caching mechanisms for repeated queries
- Indexing for faster searches

### Enhanced Search Features
- Regular expression support
- Multi-field search criteria
- Fuzzy name matching
- Search result ranking

### Additional Output Formats
- JSON output for programmatic consumption
- CSV export functionality
- Structured logging

### Improved Error Recovery
- Retry logic with exponential backoff
- Partial failure handling
- Progress indicators for long operations

## Development

### Adding New Commands

1. Create a new command class in `lib/detrack/commands/`
2. Implement the command logic following existing patterns
3. Add CLI option parsing in `cli.rb`
4. Add comprehensive tests in `spec/commands/`

### Adding New Search Types

1. Extend `ClientSearcher` with new search methods
2. Add corresponding command classes if needed
3. Update CLI to support new options
4. Add test coverage for new functionality

## License

This project is developed for evaluation purposes.