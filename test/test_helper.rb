require 'rack/test'
require 'test/unit'
require 'sinatra/base'

# Helper based on sinatra-assetpack test helper
# © 2011, Rico Sta. Cruz. Released under the MIT License 
# @link http://www.opensource.org/licenses/mit-license.php
# @link https://github.com/rstacruz/sinatra-assetpack

class UnitTest < Test::Unit::TestCase
  include Rack::Test::Methods

  class App < Sinatra::Base
    set :root, File.expand_path('../app', __FILE__)
    enable :raise_errors
    disable :show_exceptions
  end

  def setup 
    Sinatra::Base.set :environment, :test
  end

  def d
    puts "-"*80
    puts "#{last_response.status}"
    y last_response.original_headers
    puts "-"*80
    puts ""
    puts last_response.body.gsub(/^/m, '    ')
    puts ""
  end

  def body
    last_response.body.strip
  end

  def r(*a)
    File.join app.root, *a
  end

  def assert_includes(haystack, needle)
    assert haystack.include?(needle), "Expected #{haystack.inspect} to include #{needle.inspect}."
  end
end