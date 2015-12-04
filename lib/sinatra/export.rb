require 'sinatra/base'
require 'sinatra/advanced_routes'
require 'rack/test'
require 'term/ansicolor'
require 'pathname'

module Sinatra
  module Export

    def self.registered(app)
      if app.extensions.nil? or !app.extensions.include?(Sinatra::AdvancedRoutes)
        app.register Sinatra::AdvancedRoutes
      end
      app.set :export_extensions, %w(css js xml json html csv)
      app.extend ClassMethods
    end

    module ClassMethods
      def export!
        Builder.new(self).build!
      end
    end

    class Builder
      include Rack::Test::Methods

      class ColorString < String
        include Term::ANSIColor
      end

      def initialize(app)
        @app = app
      end

      def app
        @app
      end

      def build!
        dir = ENV["EXPORT_BUILD_DIR"] || app.public_folder
        handle_error_dir_not_found!(dir) unless dir.exists?(dir) && dir.directory?
        app.each_route do |route|
          next if route.verb != 'GET' or not route.path.is_a? String
          build_path(route.path, dir)
        end
      end

      private

        def build_path(path, dir)
          response = get_path(path)
          body = response.body
          mtime = response.headers.key?("Last-Modified") ?
            Time.httpdate(response.headers["Last-Modified"]) : Time.now
          file_path = file_for_path(path, dir)
          dir_path = dir_for_path(path, dir)

          dir_path.mkdir_p
          ::File.open(file_path, 'w+') do |f|
            f.write(body)
          end
          ::FileUtils.touch(file_path, :mtime => mtime)
        end

        def get_path( path)
          get(path).tap do |resp|
            handle_error_non_200!(path) unless resp.status == 200
          end
        end


        FILE_FOR_PATH_PATTERN = %r{
          [^/\.]+
          .
          (
            #{app.settings.export_extensions.join("|")}
          )
        $}x

        def file_for_path(path, dir)
          if path.match(FILE_FOR_PATH_PATTERN)
            dir.join path
          else
            dir.join( path ).join( 'index.html' )
          end
        end


        DIR_FOR_PATH_PATTERN = %r{
          (.*)
          /
          [^/]+
        $}x

        def dir_for_path(path, dir)
          file_for_path(path, dir).match(DIR_FOR_PATH_PATTERN)[1]
        end

        def handle_error_dir_not_found!(dir)
          handle_error!("can't find output directory: #{dir.to_s}")
        end

        def handle_error_non_200!(path)
          handle_error!("GET #{path} returned non-200 status code...")
        end

        def handle_error!(desc)
          puts ColorString.new("failed: #{desc}").red; exit!
        end
    end
  end

  register Sinatra::Export
end