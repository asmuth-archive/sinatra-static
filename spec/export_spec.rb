require 'spec_helper'
require 'sinatra'
require_relative "../lib/sinatra/export.rb"

describe "Sinatra Export" do

  shared_context "app" do
    def app
      Sinatra.new do
        register Sinatra::Export

        configure do
          set :root, File.join(__dir__, "support/fixtures", "app")
          enable :raise_errors
          disable :show_exceptions
        end

        get '/' do
          "homepage"
        end

        get '/contact' do
          "contact"
        end

        get '/data.json' do
          "{test: 'ok'}"
        end

        get '/yesterday' do
          last_modified Time.local(2002, 10, 31)
          "old content"
        end
      end
    end
  end

  shared_examples "Server is up" do
    before { get "/" }
    subject {  last_response }
    it { should be_ok }
  end


  context "Using the default settings" do
    include_context "app"
    include_examples "Server is up"

    describe "Exporting" do
      before :all do
        FileUtils.mkdir_p File.join(__dir__, "support/fixtures", "app/public")
        app.export!
      end

      subject {
        File.join(app.public_folder, 'index.html')
      }
      it { should be_a_kind_of String }
      it { File.read(subject).should include 'homepage' }

      after :all do
        FileUtils.rm_rf File.join(__dir__, "support/fixtures", "app" )
      end
    end
  end

  context "Using an env var" do
    before :all do
      ENV["EXPORT_BUILD_DIR"] = File.expand_path("support/fixtures/static/001", __dir__ )
    end

    include_context "app"
    include_examples "Server is up"

    describe "Exporting" do
      before :all do
        FileUtils.mkdir_p ENV["EXPORT_BUILD_DIR"]
        app.export!
      end

      subject {
        File.join(ENV["EXPORT_BUILD_DIR"], 'index.html')
      }
      it { should be_a_kind_of String }
      it { File.read(subject).should include 'homepage' }

      after :all do
        FileUtils.rm_rf ENV["EXPORT_BUILD_DIR"]
      end
    end
  
  
  end


end