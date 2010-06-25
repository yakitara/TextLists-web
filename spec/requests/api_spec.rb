require 'spec_helper'

describe "Api" do
  include RequestsSupport
  include ApplicationController::Auth
  
  before(:each) do
    #create_login_session
    @user = User.create!
  end
  
  describe "POST /api/changes" do
    context "a new record" do
      it "works" do
        key = calculate_api_key(@user.salt, "*", "*")
        change = {:name => "foo", :position => 3, :created_at => "2010-06-24T10:10:10+09:00", :updated_at => "2010-06-24T10:10:10+09:00"}
        
        post api_changes_path, {:type => "list", :change => change, :user_id => @user.id, :key => key}.to_json, {"CONTENT_TYPE" => Mime::JSON.to_s, "HTTP_ACCEPT" => Mime::JSON.to_s}
        # TODO: be a more readable spec
        response.should be_success
        ActiveSupport::JSON.decode(response.body).should have_key("id")
        ActiveSupport::JSON.decode(ChangeLog.last.json).except("user_id","id").should == change.stringify_keys
      end
    end
  end
end
