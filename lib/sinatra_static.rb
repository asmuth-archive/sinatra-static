class SinatraStatic

  attr_accessor :app

  include Rack::Test::Methods

  require 'term/ansicolor'
  class ColorString < String
    include Term::ANSIColor
  end  
  
  def initialize(app)    
    @app = app    
  end

  def build!(dir)
    handle_error_no_each_route! unless @app.respond_to?(:each_route)
    handle_error_dir_not_found!(dir) unless dir_exists?(dir)     
    build_routes(dir)
  end

private

  def build_routes(dir)
    @app.each_route do |route|     
      next unless route.verb == 'GET'      
      build_path(route.path, dir)
    end    
  end 

  def build_path(path, dir)                 
    ::FileUtils.mkdir_p(dir_for_path(path, dir))
    ::File.open(file_for_path(path, dir), 'w+') do |f| 
      f.write(get_path(path).body) 
    end    
  end

  def get_path(path)
    self.get(path).tap do |resp|      
      handle_error_non_200(route) unless resp.status == 200           
    end
  end

  def file_for_path(path, dir)
    ::File.join(dir_for_path(path, dir), 'index.html')
  end

  def dir_for_path(path, dir)
    ::File.join(dir, path)
  end

  def dir_exists?(dir)
    ::File.exists?(dir) && ::File.directory?(dir)
  end

  def handle_error!(desc)    
    puts ColorString.new("failed: #{desc}").red; exit!
  end

  # re-define ("monkeypatch") these methods at runtime to control error behaviour

  def handle_error_no_each_route!
    handle_error!("can't call app.each_route, did you include sinatra-advanced-routes?")
  end

  def handle_error_dir_not_found!(dir)  
    handle_error!("can't find output directory: #{dir}")
  end

  def handle_error_non_200!(route)
    handle_error!("GET #{route.path} returned non-200 status code...")
  end

  def env
    ENV['RACK_ENV']
  end  
  
end
