module RequestsSupport
  include ActionController::RecordIdentifier # for dom_id() helper

  def create_login_session(name=nil)
    name ||= "yakitaracom"
    client = mock(TwitterOAuth::Client)
    TwitterOAuth::Client.should_receive(:new).twice.and_return(client)
    request_token = mock(OAuth::RequestToken)
    request_token.should_receive(:token)
    request_token.should_receive(:secret)
    request_token.should_receive(:authorize_url).and_return("http://example.com")
    client.should_receive(:request_token).and_return(request_token)
    access_token = mock(OAuth::AccessToken)
    client.should_receive(:authorize).and_return(access_token)
    access_token.should_receive(:params).and_return({:screen_name => name})
    cred_count = Credential.count
    user_count = User.count
    
    visit login_path
    visit oauth_path
    
    # get login_path
    # response.should be_redirect
    
    # get oauth_path, {:oauth_verifier => "XXX"}
    # response.should be_redirect
    
#    session[:identifier].should == "yakitaracom"
    # User.count.should == user_count + 1
    # Credential.count.should == cred_count + 1
    # @current_user = User.first
    # Credential.find_by_identifier_and_user_id("yakitaracom", @current_user.id).should_not be_nil
    @current_user = User.joins(:credentials).where(:credentials => {:identifier => name}).first
  end
end
