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
      # @example
      #   app.export paths: "/" do |body|
      #     # something here
      #   end
      def export! paths: nil, skips: [], &block
        Builder.new(self).build! paths: paths, skips: skips, &block
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


      def build!( paths: nil, skips: [], &block )
        dir = Pathname( ENV["EXPORT_BUILD_DIR"] || app.public_folder )
        handle_error_dir_not_found!(dir) unless dir.exist? && dir.directory?

        if paths.nil?
          paths_e = self.send( :route_paths ).to_enum
        else
          paths_e = paths.to_enum
        end

        catch(:no_more_paths) {
          while true
            begin
              path = paths_e.next
              unless skips.include? path
                response = get_path(path)
                file_path = build_path(path: path, dir: dir, response: response)
                block.call response, path if block
              end
            rescue StopIteration
              throw(:no_more_paths)
            end
          end
        }
      end

      private


        def route_paths
          route_paths = []
          app.each_route do |route|
            next if route.verb != 'GET' or not route.path.respond_to? :to_s
            route_paths << route.path
          end
          route_paths
        end


        # @return [String] file_path
        def build_path(path:, dir:, response:)
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
          write_path content: body, path: file_path
          ::FileUtils.touch(file_path, :mtime => mtime)
          file_path
        end


        def write_path content:, path:
          ::File.open(path, 'w+') do |f|
            f.write(content)
          end
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