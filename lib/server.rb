# Creates a simple Sinatra website for the tests
require 'sinatra'
require 'haml'
require 'logger'

ROOT = File.join(File.dirname(__FILE__), '..')
set :root, ROOT
set :public, Proc.new { File.join(root, 'site') }
set :views, Proc.new { File.join(root, 'site') }
set :lib, Proc.new { File.join(root, 'lib') }

configure do
  FileUtils.mkdir_p(ROOT + "/log")
  LOGGER = Logger.new(ROOT + "/log/sinatra.log") 
end
 
helpers do
  def logger
    LOGGER
  end
end


get '/' do
  send_file File.join(settings.public, 'index.html')
end

get '/README' do
  require 'maruku'
  Maruku.new(File.read("#{settings.root}/README.markdown")).to_html
end

# Unit tests for the plugin
get '/test' do
  redirect '/test/'
end
get '/test/*' do
  file = params[:splat].join '/'
  
  if file.empty? || file == 'index.html'
    @listing = ""
    Dir.new("#{settings.root}/test/").each do | filename |
      next unless filename =~ /\.html$/
      @listing << <<-TEXT
        <li><a href="/test/#{filename}">#{filename}</a></li>
      TEXT
    end
    haml :"tests.html"
  elsif file =~ /\.html$/
    content = File.read("#{settings.root}/test/#{file}")
    @filename = /^(.+)\.html$/.match(file)[1]
    @title = /<title>(.+)<\/title>/.match(content)[1] || "Open Graph Protocol test page"
    @metatags = content.gsub(/(<title>.*<\/title>)/, "")
    haml :"test_layout.html"    
  else
    send_file File.join(settings.root, 'test', params[:splat])
  end
  
end

# QUnit is used as the test runner
get '/qunit' do
  redirect '/qunit/test/index.html'
end
get '/qunit/*' do
  send_file File.join(settings.lib, 'qunit', params[:splat])
end

# jQuery is a dependency
get '/jquery/*' do
  send_file File.join(settings.lib, 'jquery', params[:splat])
end

# Access to the plugin code
get '/src/*' do
  send_file File.join(settings.root, 'src', params[:splat])
end