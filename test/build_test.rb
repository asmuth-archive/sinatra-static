require File.expand_path('../test_helper', __FILE__)

class SinatraStaticBuildTest < UnitTest
  include Rack::Test::Methods

  class App < UnitTest::App
    get '/' do
      "homepage"
    end
    get '/contact' do
      "contact"
    end
  end

  def test_build
    # Temporary public folder
    public_path = File.join(App.root, 'public')
    FileUtils.rm_rf File.join(App.root, 'public')
    FileUtils.mkdir public_path

    builder = SinatraStatic.new(App)
    builder.build!(public_path)

    assert File.read(File.join(App.root, 'public/index.html')).include?('homepage')
    assert File.read(File.join(App.root, 'public/contact/index.html')).include?('contact')
  end

end