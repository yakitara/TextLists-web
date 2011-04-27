class NavController < ApplicationController
  before_filter :only => [:login, :oauth] do
  end
  
  
  def index
    render :nothing => true, :layout => true
  end
  
  def login
    #Rails.logger.info request.env.to_yaml
    config = Rails.application.config.oauth
    client = TwitterOAuth::Client.new(config.slice(:consumer_key, :consumer_secret))
    request_token = client.request_token(config.slice(:oauth_callback))
    session[:oauth_token] = request_token.token
    session[:oauth_secret] = request_token.secret
    session[:return_to] = params[:return_to]
    redirect_to request_token.authorize_url
  end
  
  def oauth
    config = Rails.application.config.oauth
    client = TwitterOAuth::Client.new(config.slice(:consumer_key, :consumer_secret))
    # NOTE: TwitterOAuth::Client#authorize issues an http request to the OAuth server
    access_token = client.authorize(session[:oauth_token], session[:oauth_secret], :oauth_verifier => params[:oauth_verifier])
    session[:identifier] = access_token.params[:screen_name]
    unless credential = Credential.find_by_identifier(session[:identifier])
      Credential.transaction do
        credential = Credential.create!(:identifier => session[:identifier], :user => User.create!)
      end
    end
    redirect_to session[:return_to] || root_path
  rescue Net::HTTPFatalError, OAuth::Unauthorized => e
    render :inline => "Twitter OAuth failed (#{e}).", :status => 401
  end
  
  def logout
    session.delete(:identifier)
    redirect_to root_url
  end

  def bookmarklet
  end
end
