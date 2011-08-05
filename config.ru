# This file exists to make this project Rack-compatible.
# You may delete it if you're not concerned about this.

require 'rubygems'  unless defined?(::Gem)

# Use Bundler if possible.
begin
  require 'bundler'
  Bundler.setup
rescue LoadError
  gem 'proton', '0.3.0.rc1'
end

# Add the 'rack-cache' gem if you want to enable caching.
begin
  require 'rack/cache'
  use Rack::Cache  if ENV['RACK_ENV'] == 'production'
rescue LoadError
end

# Load Proton.
require 'proton/server'
Proton::Project.new File.dirname(__FILE__)
run Proton::Server
