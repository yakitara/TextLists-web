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
    User.create! # for creating another "in-box"
    @user = User.create!
    @key = calculate_api_key(@user.salt, "*", "*")
    @auth_params = {:user_id => @user.id, :key => @key}
  end
  
  describe "POST /api/in-box/items" do
    it "change logs should be ordered as Item, Listing" do
      post api_inbox_items_path, @auth_params.merge(:item => {"content" => "foo"})
      logs = ChangeLog.all
      logs[-2].record_type.should == "Item"
      logs[-1].record_type.should == "Listing"
    end
  end
  
  describe "POST /api/changes" do
    context "a new record" do
      it "works" do
        change = {:name => "foo", :position => 3, :created_at => "2010-06-24T10:10:10+09:00", :updated_at => "2010-06-24T10:10:10+09:00"}
        post api_changes_path, @auth_params.merge(:record_type => "List", :json => change.to_json).to_json, JSON_HEADERS
        # TODO: be a more readable spec
        response.should be_success
        ActiveSupport::JSON.decode(response.body)["id"].should_not be_nil
        #ActiveSupport::JSON.decode(ChangeLog.last.json).except("user_id","id").should == change.stringify_keys
        ChangeLog.last.json.should == change.to_json
      end
    end
    
    context "post duplicated name list on server" do
      it "avoids duplication" do
        change = {:name => "in-box", :created_at => "2010-06-24T10:10:10+09:00", :updated_at => "2010-06-24T10:10:10+09:00"}
        post api_changes_path, @auth_params.merge(:record_type => "List", :json => change.to_json).to_json, JSON_HEADERS
        response.should be_success
        ActiveSupport::JSON.decode(response.body)["id"].should == @user.inbox!.id
        List.where(:user_id => @user.id, :name => "in-box").all.should have(1).inbox
      end
    end
    
    it "a same new record posted twice"
    
    context "existed record with old change" do
      it "works" do
        @list = List.create!(:user => @user, :name => "old name", :position => 3, :created_at => 1.week.ago, :updated_at => 1.week.ago)
        change = {:name => "stale name", :updated_at => 2.day.ago.as_json, :position => 0}
        @list.update_attributes!(:name => "new name", :updated_at => 1.day.ago)
        post api_changes_path, @auth_params.merge(:record_type => "List", :record_id => @list.id, :json => change.to_json).to_json, JSON_HEADERS
        response.should be_success
        @list = List.find(@list.id)
        @list.position.should == 0
        @list.name.should == "new name"
        @list.updated_at.should be_within(5.second).of(1.day.ago)
        @posted_change = ActiveSupport::JSON.decode(ChangeLog.last.json)
        @posted_change.should == change.stringify_keys
      end
    end
    
    it "an existed record posted twice"
  end
  
  describe "GET /api/changes/next/:id" do
    it "works" do
      @last_id = ChangeLog.last.id
      @list = List.create!(:user => @user, :name => "foo")
      @list.update_attributes!(:position => 3)
      # first, but newer change is get merged with
      get api_next_change_path(@last_id), @auth_params, JSON_HEADERS
      response.should be_success
      log = ActiveSupport::JSON.decode(response.body)
      change = ActiveSupport::JSON.decode(log["json"])
      change["name"].should == "foo"
      pending "merge feature currently disabled" do
        change["position"].should == 3 # any newer log get should merged
      end
      change.should have_key("id")
      @last_id = log["id"]
      # second, get the next of last_id
      get api_next_change_path(@last_id), @auth_params, JSON_HEADERS
      response.should be_success
      log = ActiveSupport::JSON.decode(response.body)
      change = ActiveSupport::JSON.decode(log["json"])
      change["position"].should == 3
    end
  end
end
