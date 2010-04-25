module RequestsSupport
  def create_login_session
    resp = stub(OpenID::Consumer)
    resp.should_receive(:status).and_return(:success)
    resp.should_receive(:display_identifier).and_return("http://example.com")
    Credential.count.should == 0
    User.count.should == 0
    
    post openid_path, {}, {"rack.openid.response" => resp}
    
    session[:openid].should == "http://example.com"
    User.count.should == 1
    @current_user = User.first
    Credential.count.should == 1
    Credential.find_by_identifier_and_user_id("http://example.com", @current_user.id).should_not be_nil
  end  
end
