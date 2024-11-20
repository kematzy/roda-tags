# frozen_string_literal: false

ENV['RACK_ENV'] = 'test'

if ENV['COVERAGE']
  require File.join(File.dirname(File.expand_path(__FILE__)), 'roda_tags_coverage')
  SimpleCov.roda_tags_coverage
end

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'rubygems'
require 'roda/tags'
require 'tilt/erubi'
require 'tilt/haml'
require 'rack/session'
require 'rack/test'
require 'minitest/autorun'
require 'minitest/have_tag'
require 'minitest/hooks/default'
require 'minitest/rg'

# Disable HTML escaping for all HAML templates in the tests.
Haml::Template.options[:escape_html] = false

# rubocop:disable Metrics/ClassLength
class Minitest::Spec # rubocop:disable Style/ClassAndModuleChildren
  include Rack::Test::Methods

  # Helper method to make a GET request and return the response body
  #
  # @param path [String] The URL path to request
  # @param _opts [Hash] Optional parameters (unused)
  #
  # @return [String] The full response body as a string
  #
  def rt(path, _opts = {})
    get path
    last_response.body
  end

  # Helper method to create or retrieve a test Roda application instance
  #
  # @param type [Symbol, nil] The type of app to create:
  #   - :new creates a fresh app with routes
  #   - :bare creates a basic app without routes
  #   - :haml creates a basic HAML app without routes
  #   - Any other symbol loads that plugin and adds routes
  #   - nil returns existing app or creates new one with routes
  # @param block [Proc] Block containing route definitions
  #
  # @return [Class] Roda application class instance for testing
  #
  # rubocop:disable Metrics/MethodLength
  def app(type = nil, &block)
    case type
    when :new
      @app = _app { route(&block) }
    when :bare
      @app = _app(&block)
    when :haml
      @app = _app_haml(&block)
    when Symbol
      @app = _app do
        plugin type
        route(&block)
      end
    else
      @app ||= _app { route(&block) }
    end
  end
  # rubocop:enable Metrics/MethodLength

  # Helper method to make a request to the test app with the specified path and environment
  #
  # @param path [String, Hash] The URL path to request or a hash of environment variables
  # @param env [Hash] Additional environment variables to merge with defaults
  #
  # @return [Array] Standard Rack response array [status, headers, body]
  #
  def req(path = '/', env = {})
    if path.is_a?(Hash)
      env = path
    else
      env['PATH_INFO'] = path
    end

    env = { 'REQUEST_METHOD' => 'GET', 'PATH_INFO' => '/', 'SCRIPT_NAME' => '' }.merge(env)
    @app.call(env)
  end

  # Helper method to get the HTTP status code from a request to the test app
  #
  # @param path [String] The URL path to request, defaults to '/'
  # @param env [Hash] Environment variables to pass with the request
  #
  # @return [Integer] The HTTP status code of the response
  #
  def status(path = '/', env = {})
    req(path, env)[0]
  end

  # Helper method to get a specific response header from a request to the test app
  #
  # @param name [String] The name of the header to retrieve
  # @param path [String] The URL path to request, defaults to '/'
  # @param env [Hash] Environment variables to pass with the request
  #
  # @return [String] The value of the specified response header
  #
  def header(name, path = '/', env = {})
    req(path, env)[1][name]
  end

  # Helper method to get the response body from a request to the test app
  #
  # @param path [String] The URL path to request, defaults to '/'
  # @param env [Hash] Environment variables to pass with the request
  #
  # @return [String] The full response body as a string
  #
  def body(path = '/', env = {})
    s = ''
    b = req(path, env)[2]
    b.each { |x| s << x }
    b.close if b.respond_to?(:close)
    s
  end

  @cookie_secret = '1756039d-725e-46bd-be72-e77dba01e42b-1756039d-725e-46bd-be72-e77dba01e42b'

  # Helper method to create a new Roda application instance for testing with ERB views
  #
  # @param block [Proc] Block containing routes and configuration for the test app
  #
  # @return [Class] New Roda application class configured for testing
  #
  # rubocop:disable Metrics/MethodLength
  def _app(&block)
    c = Class.new(Roda)
    c.plugin :render, engine: 'erb'
    c.plugin(:not_found) { raise "path #{request.path_info} not found" }
    c.use Rack::Session::Cookie, secret: @cookie_secret
    c.class_eval do
      def erb(str, opts = {})
        render(opts.merge(inline: str))
      end
    end
    c.class_eval(&block)
    c
  end
  # rubocop:enable Metrics/MethodLength

  # Helper method to create a new Roda application instance for testing with HAML views
  #
  # @param block [Proc] Block containing routes and configuration for the test app
  #
  # @return [Class] New Roda application class configured for testing
  #
  # rubocop:disable Metrics/MethodLength
  def _app_haml(&block)
    c = Class.new(Roda)
    c.plugin :render, engine: 'haml' # , escape: false
    c.plugin(:not_found) { raise "path #{request.path_info} not found" }
    c.use Rack::Session::Cookie, secret: @cookie_secret
    c.class_eval do
      def haml(str, opts = {})
        render(opts.merge(inline: str))
      end
    end
    c.class_eval(&block)
    c
  end
  # rubocop:enable Metrics/MethodLength

  # Helper method to get the body of the last response. Essentially syntactic sugar
  #
  # @return [String] The body content of the last HTTP response
  #
  def _body
    last_response.body
  end

  # Helper method to get the status code of the last response. Essentially syntactic sugar
  #
  # @return [Integer] The HTTP status code of the last response
  #
  def _status
    last_response.status
  end

  # Helper method to create a test app with the tags plugin and a simple route
  # Custom specs app
  #
  # @param view [String] The view template content to render
  # @param opts [Hash] Options to pass to the view renderer
  # @param configs [Hash] Configuration options for the tags plugin
  #
  # @return [String] The response body from requesting the root path
  #
  def tag_app(view, opts = {}, configs = {})
    app(:bare) do
      plugin(:tags, configs)
      route do |r|
        r.root do
          view(inline: view, layout: { inline: '<%= yield %>' }.merge(opts))
        end
      end
    end
    body('/')
  end

  # Helper method to create a test app with the tags plugin and a simple route
  # Custom specs app
  #
  # @param view [String] The view template content to render
  # @param opts [Hash] Options to pass to the view renderer
  # @param configs [Hash] Configuration options for the tags plugin
  #
  # @return [String] The response body from requesting the root path
  #
  def tag_haml_app(view, opts = {}, configs = {})
    app(:haml) do
      plugin(:tags, configs)
      route do |r|
        r.root do
          view(inline: view, layout: { inline: '= yield' }.merge(opts))
        end
      end
    end
    body('/')
  end

  # Helper method to create a test app with the tag_helpers plugin and a simple route
  #
  # @param view [String] The view template content to render
  # @param opts [Hash] Options to pass to the view renderer
  # @param configs [Hash] Configuration options for the tag_helpers plugin
  #
  # @return [String] The response body from requesting the root path
  #
  def tag_helpers_app(view, opts = {}, configs = {})
    app(:bare) do
      plugin(:tag_helpers, configs)
      route do |r|
        r.root do
          view(inline: view, layout: { inline: '<%= yield %>' }.merge(opts))
        end
      end
    end
    body('/')
  end
end
# rubocop:enable Metrics/ClassLength
