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
      app.set :builder, nil
    end

    module ClassMethods

      # @example
      #   # The default: Will use the paths from Sinatra Namespace
      #   app.export!
      #
      #   # Skip a path
      #   app.export! skips: ["/admin"]
      #
      #   # Only visit the homepage and the site map
      #   app.export! paths: ["/", "/site-map"]
      #
      #   # Visit the 404 error page by supplying the expected
      #   # status code (so as not to trigger an error)
      #   app.export! paths: ["/", ["/404.html",404]]
      #
      #   # Filter out mentions of localhost:4567
      #   filter = ->(content){ content.gsub("localhost:4567, "example.org") }
      #   app.export! filters: [filter]
      #
      #   # Use routes found by Sinatra AdvancedRoutes *and*
      #   # ones supplied via `paths`
      #   app.export! paths: ["/crazy/deep/page/path"], use_routes: true
      #
      #   # Supply a path and scan the output for an internal link
      #   # adding it to the list of paths to be visited
      #   app.export! paths: "/" do |builder|
      #     if builder.last_response.body.include? "/echo-1"
      #       builder.paths << "/echo-1"
      #     end
      #   end
      #
      # @param [Array<String>,Array<URI>] paths Paths that will be requested by the exporter.
      # @param [Array<String>] skips: Paths that will be ignored by the exporter.
      # @param [TrueClass] use_routes Whether to use Sinatra AdvancedRoutes to look for paths to send to the builder.
      # @param [Array<#call>] filters Filters will be applied to every file as it is written in the order given.
      # @param [#call] error_handler Define your own error handling. Takes one argument, a description of the error.
      # @yield [builder] Gives a Builder instance to the block (see Builder) that is called for every path visited.
      # @note By default the output files with be written to the public folder. Set the EXPORT_BUILD_DIR env var to choose a different location.
      def export! paths: nil, skips: [], filters: [], use_routes: nil, error_handler: nil,  &block
        @builder ||= 
          if self.builder
            self.builder
          else
            Builder.new(self, paths: paths, skips: skips, filters: filters, use_routes: use_routes, error_handler: error_handler )
          end
        @builder.build! &block
      end
    end


    # Visits the paths and builds pages from the output
    class Builder
      include Rack::Test::Methods

      # Default error handler
      # @yieldparam [String] desc Description of the error.
      DEFAULT_ERROR_HANDLER = ->(desc) {
        puts ColorString.new("failed: #{desc}").red;
      }

      class ColorString < String
        include Term::ANSIColor
      end


      # @param [Sinatra::Base] app The Sinatra app
      # @param (see ClassMethods#export!)
      # @yield [builder] Gives a Builder instance to the block (see Builder) that is called for every path visited.
      def initialize(app, paths: nil, skips: nil, use_routes: nil, filters: [], error_handler: nil )
        @app = app
        @use_routes = 
          paths.nil? && use_routes.nil? ?
            true :
            use_routes
        @paths  = paths || []
        @skips  = skips || []
        @enums  = []
        @filters  = filters
        @visited  = []
        @errored  = []
        @error_handler = error_handler || DEFAULT_ERROR_HANDLER
      end

      # @!attribute [r] last_response
      #   @return [Rack::Response] The last page requested's response
      attr_reader :last_response

      # @!attribute [r] last_path
      #   @return [String] The last path requested
      attr_reader :last_path

      # @!attribute [r] visited
      #   @return [Array<String>] List of paths visited by the builder
      attr_reader :visited

      # @!attribute [r] errored
      #   @return [Array<String>] List of paths visited by the builder that called the error handler
      attr_reader :errored

      # @!attribute [w] error_handler
      # Error handler (see ClassMethods#export!)
      #   @return [nil]
      attr_writer :error_handler

      # @!attribute paths
      # Paths to visit (see ClassMethods#export!)
      #   @return [Array<String,URI>]
      attr_accessor :paths

      # @!attribute skips
      # Paths to be skipped (see ClassMethods#export!)
      #   @return [Array<String,URI>]
      attr_accessor :skips


      def app
        @app
      end


      # Processes the routes and builds the output files.
      # @yield [builder] Gives a Builder instance to the block (see Builder) that is called for every path visited.
      def build!( &block )
        dir = Pathname( ENV["EXPORT_BUILD_DIR"] || app.public_folder )
        handle_error_dir_not_found!(dir) unless dir.exist? && dir.directory?

        if @use_routes
          @enums.push self.send( :route_paths ).to_enum
        end
        @enums.push @paths.to_enum

        catch(:no_more_paths) {
          enum = @enums.shift
          while true
            begin
              @last_path, status = enum.next
              @last_path = @last_path.respond_to?(:path) ?
                            @last_path.path :
                            @last_path.to_s
              next unless route_path_usable?(@last_path)
              next if @skips.include? @last_path
              @last_path = @last_path.chop if @last_path.end_with? "?"
              desc = catch(:status_error) {
                @last_response = get_path(@last_path, status)
                file_path = build_path(path: @last_path, dir: dir, response: last_response)
                block.call self if block
              }
              desc ?
                @errored |= [@last_path] :
                @visited |= [@last_path]
            rescue StopIteration
              retry if enum = @enums.shift
              throw(:no_more_paths)
            end
          end
        }
        self
      end

      private

        # a convenience wrapper for throwing status errors
        def status_error desc
          throw :status_error, desc
        end

        # A convenience method to keep this logic together
        # and reusable
        # @param [String,Regexp] path
        # @return [TrueClass] Whether the path is a straightforward path (i.e. usable) or it's a regex or path with named captures / wildcards (i.e. unusable).
        def route_path_usable? path
          res = path.respond_to?( :~ )  ||  # skip regex
                path =~ /(?:\:\w+)|\*/  ||  # keys and splats
                path =~ /[\%\\]/        ||  # special chars
                path[0..-2].include?("?") # an ending ? is acceptable, it'll be chomped
          !res
        end


        def route_paths
          route_paths = []
          app.each_route do |route|
            next if route.verb != 'GET'
            next unless route_path_usable?(route.path)
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
          if @filters && !@filters.empty?
            content = @filters.inject(content) do |current_content,filter|
              filter.call current_content
            end
          end
          ::File.open(path, 'w+') do |f|
            f.write(content)
          end
        end


        def get_path path, status=nil
          status ||= 200
          get(path).tap do |resp|
            handle_error_incorrect_status!(path,expected: status, actual: resp.status) unless resp.status == status
          end
        end


        def handle_error_dir_not_found!(dir)
          @error_handler.call("can't find output directory: #{dir.to_s}")
        end

        def handle_error_incorrect_status!(path,expected:,actual:)
          desc = "GET #{path} returned #{actual} status code instead of #{expected}"
          @error_handler.call(desc)
          status_error desc
        end
    end
  end

  register Sinatra::Export
end