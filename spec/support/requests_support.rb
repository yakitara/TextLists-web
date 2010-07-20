module RequestsSupport
#   def create_login_session
#     resp = stub(OpenID::Consumer)
#     resp.should_receive(:status).and_return(:success)
#     resp.should_receive(:display_identifier).and_return("http://example.com")
#     Credential.count.should == 0
#     User.count.should == 0
    
#     post openid_path, {}, {"rack.openid.response" => resp}
    
#     session[:openid].should == "http://example.com"
#     User.count.should == 1
#     @current_user = User.first
#     Credential.count.should == 1
#     Credential.find_by_identifier_and_user_id("http://example.com", @current_user.id).should_not be_nil
#   end  
  def create_login_session
    client = mock(TwitterOAuth::Client)
    TwitterOAuth::Client.should_receive(:new).twice.and_return(client)
    request_token = mock(OAuth::RequestToken)
    request_token.should_receive(:token)
    request_token.should_receive(:secret)
    request_token.should_receive(:authorize_url).and_return("http://example.com")
    client.should_receive(:request_token).and_return(request_token)
    access_token = mock(OAuth::AccessToken)
    client.should_receive(:authorize).and_return(access_token)
    access_token.should_receive(:params).and_return({:screen_name => "yakitaracom"})
    Credential.count.should == 0
    User.count.should == 0
    
    get login_path
    response.should be_redirect
    
    get oauth_path, {:oauth_verifier => "XXX"}
    response.should be_redirect
    
    session[:identifier].should == "yakitaracom"
    User.count.should == 1
    @current_user = User.first
    Credential.count.should == 1
    Credential.find_by_identifier_and_user_id("yakitaracom", @current_user.id).should_not be_nil
  end
end
