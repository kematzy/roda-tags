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
require 'rack/session'
require 'rack/test'
require 'minitest/autorun'
require 'minitest/have_tag'
require 'minitest/hooks/default'
require 'minitest/rg'


class Minitest::Spec # rubocop:disable Style/ClassAndModuleChildren
  include Rack::Test::Methods

  def rt(path, _opts = {})
    get path
    last_response.body
  end

  # rubocop:disable Metrics/MethodLength
  def app(type = nil, &block)
    case type
    when :new
      @app = _app { route(&block) }
    when :bare
      @app = _app(&block)
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

  def req(path = '/', env = {})
    if path.is_a?(Hash)
      env = path
    else
      env['PATH_INFO'] = path
    end

    env = { 'REQUEST_METHOD' => 'GET', 'PATH_INFO' => '/', 'SCRIPT_NAME' => '' }.merge(env)
    @app.call(env)
  end

  def status(path = '/', env = {})
    req(path, env)[0]
  end

  def header(name, path = '/', env = {})
    req(path, env)[1][name]
  end

  def body(path='/', env={})
  def body(path = '/', env = {})
    s = ''
    b = req(path, env)[2]
    b.each { |x| s << x }
    b.close if b.respond_to?(:close)
    s
  end

  @cookie_secret = '1756039d-725e-46bd-be72-e77dba01e42b-1756039d-725e-46bd-be72-e77dba01e42b'

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

  # syntactic sugar
  def _body
    last_response.body
  end
  
  # syntactic sugar
  def _status
    last_response.status
  end
    
  # Custom specs app
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
