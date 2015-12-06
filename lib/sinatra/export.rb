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
      def export! paths: nil, skips: []
        Builder.new(self).build! paths: paths, skips: skips
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


      def build! paths: nil, skips: []
        dir = Pathname( ENV["EXPORT_BUILD_DIR"] || app.public_folder )
        handle_error_dir_not_found!(dir) unless dir.exist? && dir.directory?

        paths = self if paths.nil?

        paths.send( :each ) do |path|
          #next if skips.include? path
          build_path(path, dir)
        end
      end

      private


        def each
          app.each_route do |route|
            next if route.verb != 'GET' or not route.path.respond_to? :to_s
            yield route.path
          end
        end

        def build_path(path, dir)
          response = get_path(path)
          body = response.body
          mtime = response.headers.key?("Last-Modified") ?
            Time.httpdate(response.headers["Last-Modified"]) : Time.now

          pattern = %r{
            [^/\.]+
            \.
            (
              #{app.settings.export_extensions.join("|")}
            )
          $}x
          file_path = Pathname( File.join dir, path )
          file_path = file_path.join( 'index.html' ) unless  path.match(pattern)
          ::FileUtils.mkdir_p( file_path.dirname )
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