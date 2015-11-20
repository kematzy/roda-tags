ENV['RACK_ENV'] = 'test'
if ENV['COVERAGE']
  require File.join(File.dirname(File.expand_path(__FILE__)), "roda_tags_coverage")
  SimpleCov.roda_tags_coverage
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'rubygems'
require 'roda/tags'
require 'tilt/erubis'
require 'rack/test'
require 'minitest/autorun'
require 'minitest/hooks/default'
require 'minitest/rg'


class Minitest::Spec
  include Rack::Test::Methods
  
  def rt(path,opts={})
    get path
    last_response.body
  end
  
  def app(type=nil, &block)
    case type
    when :new
      @app = _app{route(&block)}
    when :bare
      @app = _app(&block)
    when Symbol
      @app = _app do
        plugin type
        route(&block)
      end
    else
      @app ||= _app{route(&block)}
    end
  end

  def req(path='/', env={})
    if path.is_a?(Hash)
      env = path
    else
      env['PATH_INFO'] = path
    end

    env = {"REQUEST_METHOD" => "GET", "PATH_INFO" => "/", "SCRIPT_NAME" => ""}.merge(env)
    @app.call(env)
  end

  def status(path='/', env={})
    req(path, env)[0]
  end

  def header(name, path='/', env={})
    req(path, env)[1][name]
  end

  def body(path='/', env={})
    s = ''
    b = req(path, env)[2]
    b.each{|x| s << x}
    b.close if b.respond_to?(:close)
    s
  end

  def _app(&block)
     c = Class.new(Roda)
     c.plugin :render
     c.plugin(:not_found){raise "path #{request.path_info} not found"}
     c.use Rack::Session::Cookie, :secret=>'topsecret'
     c.class_eval do
       def erb(s, opts={})
         render(opts.merge(:inline=>s))
       end
     end
     c.class_eval(&block)
     c
  end

  # syntactic sugar
  def _body
    last_response.body
  end
  
  # syntactic sugar
  def _status
    last_response.status
  end
    
  # Custom specs app
  def tag_app(view, opts={}, configs={})
    app(:bare) do
      plugin(:tags, configs)
      route do |r|
        r.root do
          view(inline: view, layout: {inline: '<%= yield %>'}.merge(opts))
        end
      end
    end
    body('/')
  end
  
  def tag_helpers_app(view, opts={}, configs={})
    app(:bare) do
      plugin(:tag_helpers, configs)
      route do |r|
        r.root do
          view(inline: view, layout: {inline: '<%= yield %>' }.merge(opts))
        end
      end
    end
    body('/')
  end
  
end


class Minitest::Spec 
  require 'nokogiri'
  
  def assert_have_tag(actual, expected, contents=nil, msg=nil)
    msg = msg.nil? ? '' : "#{msg}\n"
    msg << "Expected #{actual.inspect} to have tag [#{expected.inspect}]"
    
    doc = Nokogiri::HTML(actual)
    res  = doc.css(expected)
    
    if res.empty?
      msg << ", but no such tag was found"
      matching = false
    else
      # such a tag was found
      matching = true
      
      if contents
        if contents.kind_of?(String)
          if res.inner_html == contents
            matching = true
          else
            msg << " with contents [#{contents.inspect}], but the tag content is [#{res.inner_html}]"
            matching = false
          end
        elsif contents.kind_of?(Regexp)
          if res.inner_html =~ contents
            matching = true
          else
            msg << " with inner_html [#{res.inner_html}], but did not match Regexp [#{contents.inspect}]"
            matching = false
          end
        else
          msg << ", ERROR: contents is neither String nor Regexp, it's [#{contents.class}]"
          matching = false
        end
      else
        # no contents given, so ignore
      end
    end
    assert matching, msg
  end
  
  def refute_have_tag(actual, expected, contents=nil, msg=nil)
    msg = msg.nil? ? '' : "#{msg}\n"
    msg << "Expected #{actual.inspect} to NOT have tag [#{expected.inspect}]"
    
    doc = Nokogiri::HTML(actual)
    res  = doc.css(expected)
    
    unless res.empty?
      msg << ", but such a tag was found"
      matching = true
    else
      # such a tag was found, BAD
      matching = false
      
      if contents
        if contents.kind_of?(String)
          if res.inner_html == contents
            matching = false
          else
            msg << " with contents [#{contents.inspect}], but the tag content is [#{res.inner_html}]"
            matching = true
          end
        elsif contents.kind_of?(Regexp)
          if res.inner_html =~ contents
            matching = false
          else
            msg << " with inner_html [#{res.inner_html}], but did not match Regexp [#{contents.inspect}]"
            matching = true
          end
        else
          msg << ", ERROR: contents is neither String nor Regexp, it's [#{contents.class}]"
          matching = true
        end
      else
        # no contents given, so ignore
      end
    end
    refute matching, msg
  end
  
end


module Minitest::Expectations
  infect_an_assertion :assert_have_tag, :must_have_tag, :reverse
  infect_an_assertion :refute_have_tag, :wont_have_tag, :reverse
end
