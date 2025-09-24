#!/usr/bin/env ruby

require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: ruby run_tests.rb [options]"

  opts.on('-u', '--unit', 'Run unit tests only (excludes network integration)') do
    options[:unit] = true
  end

  opts.on('-i', '--integration', 'Run network integration tests only') do
    options[:integration] = true
  end

  opts.on('-a', '--all', 'Run all tests including network integration (default)') do
    options[:all] = true
  end

  opts.on('-f', '--format FORMAT', 'Specify output format (progress, documentation, json)') do |format|
    options[:format] = format
  end

  opts.on('-c', '--coverage', 'Generate coverage report (HTML format)') do
    options[:coverage] = true
  end

  opts.on('-h', '--help', 'Show this message') do
    puts opts
    exit
  end
end.parse!

# Default to all tests if no option specified
options[:all] = true if !options[:unit] && !options[:integration]

# Build RSpec command
cmd_parts = ['bundle', 'exec', 'rspec']

if options[:unit]
  cmd_parts << '--exclude-pattern="spec/integration/*"'
elsif options[:integration]
  cmd_parts << 'spec/integration/'
end

if options[:format]
  cmd_parts << '--format' << options[:format]
end

# Execute the command
cmd = cmd_parts.join(' ')
puts "Running: #{cmd}"
puts "=" * 50

exec cmd

# Note about coverage
if options[:coverage]
  puts "\nAfter tests complete, view coverage report with:"
  puts "open coverage/index.html"
end