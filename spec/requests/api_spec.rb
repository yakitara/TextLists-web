# -*- coding: utf-8 -*-
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
      logs = @user.change_logs.all
      logs[-2].record_type.should == "Item"
      logs[-1].record_type.should == "Listing"
    end
  end
  
  describe "POST /api/changes" do
    context "a new record" do
      before do
        @change = {:name => "foo", :position => 3, :created_at => "2010-06-24T10:10:10+0000", :updated_at => "2010-06-24T10:10:10+0000"}
        post api_changes_path, @auth_params.merge(:record_type => "List", :json => @change.to_json).to_json, JSON_HEADERS
      end
      it { response.should be_success }
      context "id in the response " do
        it { ActiveSupport::JSON.decode(response.body)["id"].should_not be_nil }
      end
      context"the last change log" do
        it("equal to the given change"){ @user.change_logs.last.json.should == @change.to_json }
      end
    end
    
    it "an update"
    
    context "multiple records" do
      before do
        @timestamp = "2010-06-24T10:10:10+0000"
        @list_uuid = "cfe7df54-5c0b-4616-914d-a76dd8f14ce1"
        @changes = [
          {
            :record_type => "List", 
            :json => {:name => "foo", :position => 3, :created_at => @timestamp, :updated_at => @timestamp, :uuid => @list_uuid}.to_json
          },
          {
            :record_type => "Item", :record_id => items(:item_a).id,
            :json => {:content => "updated", :updated_at => @timestamp}.to_json
          },
          {
            :record_type => "Listing",
            :json => {:item_id => items(:item_a).id, :list_uuid => @list_uuid, :updated_at => @timestamp}.to_json
          },
        ]
        post api_changes_path, @auth_params.merge(:changes => @changes).to_json, JSON_HEADERS
        @list = List.where(:name => "foo").last
        @listing = @list.listings.where(:item_id => items(:item_a).id).first
      end
      it { response.should be_success }
      it "creates new list named 'foo'" do
        @list.should_not be_nil
      end
      context "updated item" do
        subject { items(:item_a, true) }
        its(:content) { should == "updated" }
        its(:updated_at) { should == DateTime.parse(@timestamp) }
      end
      it "response body as expected" do
        response.body.should == [{:id => @list.id}, {:id => items(:item_a).id}, {:id => @listing.id}].to_json
      end
    end
    
    context "post duplicated name list on server" do
      it "avoids duplication" do
        change = {:name => "in-box", :created_at => "2010-06-24T10:10:10+0000", :updated_at => "2010-06-24T10:10:10+0000"}
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
        @posted_change = ActiveSupport::JSON.decode(@user.change_logs.last.json)
        @posted_change.should == change.stringify_keys
      end
    end
    
    it "an existed record posted twice"

    it "ensures a bugfix, a listing failed to belongs to uuid of a deleted list", :bugfix => true do
      @changes = [
        {"created_at"=>"2011-05-08T23:06:03+0900", "record_type"=>"List", "json"=>"{\"name\":\"in-box\",\"created_at\":\"2011-05-08T22:20:49+0900\",\"updated_at\":\"2011-05-08T22:20:49+0900\",\"uuid\":\"294F769C-FE57-494D-A65B-844EDC899E93\",\"position\":999}"},
        {"created_at"=>"2011-05-08T23:06:03+0900", "record_type"=>"List", "json"=>"{\"name\":\"テスト\",\"deleted_at\":\"2011-05-08T22:53:52+0900\",\"position\":999,\"updated_at\":\"2011-05-08T22:53:52+0900\",\"uuid\":\"3DF44D43-211C-4A06-9732-577F5F36B650\",\"created_at\":\"2011-05-08T22:21:01+0900\"}"},
        {"created_at"=>"2011-05-08T23:06:03+0900", "record_type"=>"Item", "json"=>"{\"updated_at\":\"2011-05-08T22:21:13+0900\",\"content\":\"テスト\",\"uuid\":\"C2BB9FDD-0E4D-49BA-9ADC-9CB49678726D\",\"created_at\":\"2011-05-08T22:21:13+0900\"}"},
        {"created_at"=>"2011-05-08T23:06:03+0900", "record_type"=>"Item", "json"=>"{\"updated_at\":\"2011-05-08T22:21:38+0900\",\"content\":\"テスト\",\"uuid\":\"0472F957-4EFD-4AC6-B974-59F810C17A06\",\"created_at\":\"2011-05-08T22:21:38+0900\"}"},
        {"created_at"=>"2011-05-08T23:06:03+0900", "record_type"=>"Listing", "json"=>"{\"list_uuid\":\"3DF44D43-211C-4A06-9732-577F5F36B650\",\"item_uuid\":\"C2BB9FDD-0E4D-49BA-9ADC-9CB49678726D\",\"position\":0,\"created_at\":\"2011-05-08T22:21:13+0900\",\"deleted_at\":\"2011-05-08T22:53:52+0900\",\"updated_at\":\"2011-05-08T22:53:52+0900\",\"uuid\":\"6D8B2A3B-922F-471A-956D-5B234E55FE24\"}"},
        {"created_at"=>"2011-05-08T23:06:03+0900", "record_type"=>"Listing", "json"=>"{\"list_uuid\":\"3DF44D43-211C-4A06-9732-577F5F36B650\",\"item_uuid\":\"0472F957-4EFD-4AC6-B974-59F810C17A06\",\"position\":0,\"created_at\":\"2011-05-08T22:21:38+0900\",\"deleted_at\":\"2011-05-08T22:53:52+0900\",\"updated_at\":\"2011-05-08T22:53:52+0900\",\"uuid\":\"A0A659AB-3BAA-4C11-BABF-21F9E96A611F\"}"}
      ]
      post api_changes_path, @auth_params.merge(:changes => @changes).to_json, JSON_HEADERS
    end
  end


  describe "GET /api/0.3/changes/:id/next/:limit" do
    context "response multiple change_logs" do
      before do
        @new_list = @user.lists.create!(:name => "new list")
        @new_list.update_attributes!(:position => 0)
        @user.inbox!.update_attributes!(:position => 1)
        get api_change_next_path(0.3, 0, 3), @auth_params, JSON_HEADERS
        @logs = ActiveSupport::JSON.decode(response.body)
      end
      describe "response" do
        it { response.should be_success }
        subject { @logs }
        it { should be_kind_of Array }
        it { should have(3).items }
        it ", but total 4 changes" do
          @user.should have(4).change_logs
        end
      end
    end
    context "last change_log" do
      before do
        @last_log = @user.change_logs.last
      end
      context "is updated" do
        before do
          @last_log.update_attribute(:changed_at, @last_log.changed_at + 2.second)
          get api_change_next_path(0.3, @last_log.id, 3), @auth_params, JSON_HEADERS
          @response_json = ActiveSupport::JSON.decode(response.body)
        end
        it { response.should be_success }
        describe "response JSON" do
          subject { @response_json }
          it { should be_kind_of Array }
          it { should have(1).item }
          it "has same log id as given" do
            subject[0]["id"].should == @last_log.id
          end
        end
      end
      context "is not updated" do
        before do
          get api_change_next_path(0.3, @last_log.id, 3), @auth_params, JSON_HEADERS
        end
        subject { response.status_message }
        it { should == "No Content" }
      end
    end
  end
  
  describe "GET /api/changes/next/:id (DEPRECATED API)" do
    it "works" do
      @last_id = @user.change_logs.last.id
      @list = List.create!(:user => @user, :name => "foo")
      @list.update_attributes!(:position => 3)
      # first, but newer change is get merged with
      get api_next_change_path(@last_id), @auth_params, JSON_HEADERS
      response.should be_success
      log = ActiveSupport::JSON.decode(response.body)
      change = ActiveSupport::JSON.decode(log["json"])
      change["name"].should == "foo"
      # pending "merge feature currently disabled" do
      #   change["position"].should == 3 # any newer log get should merged
      # end
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
