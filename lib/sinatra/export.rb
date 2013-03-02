require 'rack/test'
require 'term/ansicolor'

module Sinatra
  class Export

    @@file_extensions = %w(css js xml json html csv)

    attr_accessor :app

    include Rack::Test::Methods


    class ColorString < String
      include Term::ANSIColor
    end

    def initialize(app)
      @app = app
    end

    def build!
      dir = @app.public_folder
      handle_error_no_each_route! unless @app.respond_to?(:each_route)
      handle_error_dir_not_found!(dir) unless dir_exists?(dir)
      build_routes(dir)
    end

  private

    def build_routes(dir)
      @app.each_route do |route|
        next if route.verb != 'GET' or not route.path.is_a? String
        build_path(route.path, dir)
      end
    end

    def build_path(path, dir)
      response = get_path(path)
      body = response.body
      mtime = response.headers.key?("Last-Modified") ?
        Time.httpdate(response.headers["Last-Modified"]) : Time.now
      file_path = file_for_path(path, dir)
      dir_path = dir_for_path(path, dir)

      ::FileUtils.mkdir_p(dir_path)
      ::File.open(file_path, 'w+') do |f|
        f.write(body)
      end
      ::FileUtils.touch(file_path, :mtime => mtime)
    end

    def get_path(path)
      self.get(path).tap do |resp|
        handle_error_non_200!(path) unless resp.status == 200
      end
    end

    def file_for_path(path, dir)
      if path.match(/[^\/\.]+.(#{file_extensions.join("|")})$/)
        ::File.join(dir, path)
      else
        ::File.join(dir, path, 'index.html')
      end
    end

    def dir_exists?(dir)
      ::File.exists?(dir) && ::File.directory?(dir)
    end

    def dir_for_path(path, dir)
      file_for_path(path, dir).match(/(.*)\/[^\/]+$/)[1]
    end

    def file_extensions
      @@file_extensions
    end

    def env
      ENV['RACK_ENV']
    end

    def handle_error_no_each_route!
      handle_error!("can't call app.each_route, did you include sinatra-advanced-routes?")
    end

    def handle_error_dir_not_found!(dir)
      handle_error!("can't find output directory: #{dir}")
    end

    def handle_error_non_200!(path)
      handle_error!("GET #{path} returned non-200 status code...")
    end

    def handle_error!(desc)
      puts ColorString.new("failed: #{desc}").red; exit!
    end

  end
end