#!/usr/bin/env ruby

puts "DeTrack Code Coverage Check"
puts "=" * 40

# Check if SimpleCov is available
begin
  require 'simplecov'
  puts "✅ SimpleCov is available"
rescue LoadError
  puts "❌ SimpleCov not found. Run: bundle install"
  exit(1)
end

puts "\nRunning test suite with coverage analysis..."
puts "This will generate:"
puts "- Console coverage summary"
puts "- HTML coverage report at coverage/index.html"
puts

# Run tests with coverage
system('bundle exec rspec --exclude-pattern="spec/integration/*"')

puts "\nCoverage report generated!"
puts "View detailed report: open coverage/index.html"
puts "Or check the console output above for a quick summary."