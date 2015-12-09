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
      #   app.export paths: "/" do |builder|
      #     if builder.last_response.body.include? "/echo-1"
      #       builder.paths << "/echo-1"
      #     end
      #   end
      def export! paths: nil, skips: [], &block
        @builder ||= Builder.new(self,paths: paths, skips: skips).build! &block
      end
    end

    class Builder
      include Rack::Test::Methods

      class ColorString < String
        include Term::ANSIColor
      end


      # @param [Sinatra::Base] app The Sinatra app
      # @param [Array] paths Paths that will be requested by the builder.
      # @param [Array] skips: Paths that will be ignored by the builder.
      # @param [TrueClass] use_routes Whether to use Sinatra AdvancedRoutes to look for paths to send to the builder.
      def initialize(app, paths: nil, skips: nil, use_routes: nil )
        @app = app
        @use_routes = 
          paths.nil? && use_routes.nil? ?
            true :
            use_routes
        @paths = paths || []
        @skips = skips || []
        @enum = []
      end

      attr_accessor :paths, :skips, :last_response, :last_path

      def app
        @app
      end


      def build!( &block )
        dir = Pathname( ENV["EXPORT_BUILD_DIR"] || app.public_folder )
        handle_error_dir_not_found!(dir) unless dir.exist? && dir.directory?

        if @use_routes
          @enum.push self.send( :route_paths ).to_enum
        end
        @enum.push @paths.to_enum    

        catch(:no_more_paths) {
          enum = get_enum
          while true
            begin
              last_path = enum.next
              next if last_path =~ /((:\w+)|\*)/ # keys and splats
              next if @skips.include? last_path
              @last_response = get_path(last_path)
              file_path = build_path(path: last_path, dir: dir, response: last_response)
              block.call self if block
            rescue StopIteration
              retry if enum = get_enum
              throw(:no_more_paths)
            end
          end
        }
      end

      private

        def get_enum
          @enum.shift
        end


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