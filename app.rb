#coding:utf-8

require 'rubygems'
require 'sinatra'
require 'oauth'
require 'twitter'

helpers do
  include Rack::Utils 
  alias_method :h, :escape_html
end

configure do
	use Rack::Session::Cookie, :secret => Digest::SHA1.hexdigest(rand.to_s)
	KEY = "Consumer key"
	SECRET = "Consumer secret"
end

def configure_twitter_token
  Twitter.configure do |config|
    config.consumer_key = KEY
    config.consumer_secret = SECRET
    config.oauth_token = session[:access_token]
    config.oauth_token_secret = session[:access_token_secret]
  end
end

before do
	@title = "Simple Twitter Sinatra"
	if session[:access_token]		
		configure_twitter_token
		@twitter = Twitter::Client.new
	else
		@twitter = nil
	end
end

def base_url
	default_port = (request.scheme == "http") ? 80 : 443
	port = (request.port == default_port) ? "" : ":#{request.port.to_s}"	
	return  "#{request.scheme}://#{request.host}#{port}"
end


def oauth_consumer
	return  OAuth::Consumer.new(KEY, SECRET, :site => "http://twitter.com")
end


get '/' do
	if @twitter
		haml :timeline
	else
		haml :login
	end
end

get '/request_token' do
	callback_url = "#{base_url}/access_token"
	request_token = oauth_consumer.get_request_token( :oauth_callback => callback_url )
	session[:request_token] = request_token.token
	session[:request_token_secret] = request_token.secret
	redirect request_token.authorize_url
end

get '/access_token' do
	request_token = OAuth::RequestToken.new(oauth_consumer, session[:request_token], session[:request_token_secret])
	begin
		@access_token = request_token.get_access_token(
				{},
				:oauth_token => params[:oauth_token],
				:oauth_verifier => params[:oauth_verifier])
	rescue OAuth::Unauthorized => @exception
		return erb %{ oauth failed: <%=h @exception.message %> }
	end
	session[:access_token] = @access_token.token
	session[:access_token_secret] = @access_token.secret
	redirect '/'
end

post '/' do
	@twitter.update(params[:tweet]);
	redirect '/'
end