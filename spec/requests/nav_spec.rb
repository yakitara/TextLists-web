require 'spec_helper'

describe "Nav" do
  include RequestsSupport
  
  describe "GET /" do
    before(:all) do
      get root_path
    end
    it { response.should be_success }
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
        #get bookmarklet_path(:format => "html")
        visit bookmarklet_path(:format => "html")
        #response.should be_success
        within :css, "textarea" do
          page.should have_content("javascript:")
        end
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
