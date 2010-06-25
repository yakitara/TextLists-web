require 'spec_helper'

# When hang at /usr/local/rvm/gems/ruby-1.9.2-preview3/gems/activerecord-3.0.0.beta4/lib/active_record/base.rb:1041:in `method_missing'
# try this
# class Object
#   class << self
#     def method_missing_with_dump_caller(method_id, *arguments, &block)
#       pp caller
#       method_missing_without_dump_caller(method_id, *arguments, &block)
#     end
#     alias_method_chain :method_missing, :dump_caller
#   end
# end


describe "Api" do
  include RequestsSupport
  include ApplicationController::Auth
  
  JSON_HEADERS = {"CONTENT_TYPE" => Mime::JSON.to_s, "HTTP_ACCEPT" => Mime::JSON.to_s}
  
  before(:each) do
    #create_login_session
    @user = User.create!
    @key = calculate_api_key(@user.salt, "*", "*")
  end
  
  describe "POST /api/changes" do
    context "a new record" do
      it "works" do
        change = {:name => "foo", :position => 3, :created_at => "2010-06-24T10:10:10+09:00", :updated_at => "2010-06-24T10:10:10+09:00"}
        post api_changes_path, {:type => "list", :change => change, :user_id => @user.id, :key => @key}.to_json, JSON_HEADERS
        # TODO: be a more readable spec
        response.should be_success
        ActiveSupport::JSON.decode(response.body).should have_key("id")
        ActiveSupport::JSON.decode(ChangeLog.last.json).except("user_id","id").should == change.stringify_keys
      end
    end
    
    context "existed record with old change" do
      it "works" do
        @list = List.create!(:user => @user, :name => "old name", :position => 3, :created_at => 1.week.ago, :updated_at => 1.week.ago)
        change = {:name => "stale name", :updated_at => 2.day.ago.as_json, :position => 0}
        @list.update_attributes!(:name => "new name", :updated_at => 1.day.ago)
        post api_changes_path, {:type => "list", :id => @list.id, :change => change, :user_id => @user.id, :key => @key}.to_json, JSON_HEADERS
        response.should be_success
        @list = List.find(@list.id)
        @list.position.should == 0
        @list.name.should == "new name"
        @list.updated_at.should be_close(1.day.ago, 1.second)
        @posted_change = ActiveSupport::JSON.decode(ChangeLog.last.json)
        @posted_change.should == change.stringify_keys
      end
    end
  end
end
