require 'spec_helper'

describe "Nav" do
  include RequestsSupport
  
  describe "GET /" do
    before(:all) do
      get root_path
    end
    it { response.should be_success }
  end
  
  describe "GET /login -> /openid" do
    before(:all) do
      get login_path
    end
    it { response.should be_success }
    it "the login form should work" do
      # TODO: be more precise
      fill_in "identifier", :with => "http://example.com/"
      click_button "login"
      #response.should redirect_to("http://example.com/")
    end
  end
  
  describe "POST /openid" do
    context "First time" do
      it "works" do
        resp = stub(OpenID::Consumer)
        resp.should_receive(:status).and_return(:success)
        resp.should_receive(:display_identifier).and_return("http://example.com")
        Credential.count.should == 0
        User.count.should == 0
        
        post openid_path, {}, {"rack.openid.response" => resp}
        
        session[:openid].should == "http://example.com"
        User.count.should == 1
        user = User.first
        Credential.count.should == 1
        Credential.find_by_identifier_and_user_id("http://example.com", user.id).should_not be_nil
      end
    end
    context "Not first time" do
      it "works"
    end
    context "OpenID server returns failure" do
      it "doesn't work"
    end
  end

  describe "DELETE /logout" do
    before(:each) do
      # FIXME: set a session key
      #session[:openid] = "http://example.com/"
      delete logout_path
    end
    it do
      session.should_not have_key(:openid)
    end
    it { response.should redirect_to(root_path) }
  end

  describe "GET /bookmarklet" do
    context ".html" do
      before(:each) do
        create_login_session
      end
      
      it "works" do
        get bookmarklet_path(:format => "html")
        response.should be_success
      end
    end
    context ".js" do
      it "works" do
        get bookmarklet_path(:format => "js")
        response.should be_success
      end
    end
  end
end
