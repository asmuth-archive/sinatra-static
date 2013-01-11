# Rake task based on sinatra-assetpack test helper
# © 2011, Rico Sta. Cruz. Released under the MIT License 
# @link http://www.opensource.org/licenses/mit-license.php
# @link https://github.com/rstacruz/sinatra-assetpack

unless defined?(APP_FILE) && defined?(APP_CLASS)
  $stderr.write "Error: Please set APP_FILE, APP_CLASS before setting up Sinatra::Export rake tasks.\n"
  $stderr.write "Example:\n"
  $stderr.write "    APP_FILE  = 'app.rb'\n"
  $stderr.write "    APP_CLASS = 'App'\n"
  $stderr.write "    require 'sinatra/export/rake'\n"
  $stderr.write "\n"
  exit
end

def class_from_string(str)
  str.split('::').inject(Object) do |mod, class_name|
    mod.const_get(class_name)
  end
end

def app
  require File.expand_path(APP_FILE, Dir.pwd)
  class_from_string(APP_CLASS)
end

namespace :sinatra do
  desc "Export static application"
  task :export do
    require 'sinatra/export'
    Sinatra::Export.new(app).build!
  end
end