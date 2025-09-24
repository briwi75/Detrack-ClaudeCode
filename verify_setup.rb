#!/usr/bin/env ruby

puts "DeTrack Setup Verification Script"
puts "=" * 40

# Check Ruby version
puts "Ruby version: #{RUBY_VERSION}"
required_version = '3.4.6'

if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new(required_version)
  puts "✅ Ruby version requirement met (#{required_version}+)"
else
  puts "❌ Ruby version requirement not met (need #{required_version}+)"
  puts "   Current: #{RUBY_VERSION}"
  exit(1)
end

# Check if bundler is available
begin
  require 'bundler'
  puts "✅ Bundler is available"
rescue LoadError
  puts "❌ Bundler not found. Install with: gem install bundler"
  exit(1)
end

# Check if gems are installed
begin
  require 'json'
  puts "✅ JSON gem is available"
rescue LoadError
  puts "❌ JSON gem not found. Run: bundle install"
  exit(1)
end

begin
  require 'rspec'
  puts "✅ RSpec gem is available"
rescue LoadError
  puts "❌ RSpec gem not found. Run: bundle install"
  exit(1)
end

# Check if DeTrack loads properly
begin
  require_relative 'lib/detrack'
  puts "✅ DeTrack application loads successfully"
rescue => e
  puts "❌ Failed to load DeTrack application: #{e.message}"
  exit(1)
end

puts ""
puts "🎉 All checks passed! DeTrack is ready to use."
puts ""
puts "Try running:"
puts "  ./bin/detrack --help"
puts "  ./bin/detrack --search \"John\""
puts "  bundle exec rspec"