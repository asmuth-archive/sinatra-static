# encoding: UTF-8

require 'rspec'
require 'rspec/its'
Spec_dir = File.expand_path( File.dirname __FILE__ )


# code coverage
require 'simplecov'
SimpleCov.start do
  add_filter "/vendor/"
  add_filter "/bin/"
  add_filter "/spec/"
end

require "rack/test"
ENV['RACK_ENV'] ||= 'test'
ENV["EXPECT_WITH"] ||= "racktest"


require "logger"
logger = Logger.new STDOUT
logger.level = Logger::DEBUG
logger.datetime_format = '%a %d-%m-%Y %H%M '
LOgger = logger


Dir[ File.join( Spec_dir, "/support/**/*.rb")].each do |f| 
  logger.info "requiring #{f}"
  require f
end


RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.expect_with(:rspec) { |c| c.syntax = :should }
end

