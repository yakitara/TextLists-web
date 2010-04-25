require 'spec_helper'

describe "Items" do
  include RequestsSupport
  
  before(:each) do
    create_login_session
  end
  
  describe "new -> create -> update" do
    it "works" do
      @list = @current_user.lists.create!(:name => "foo")
      
      get list_items_path(@list.id)
      response.should be_success
      click_link "new item"
      # new -> create
      fill_in "item[content]", :with => "hoge"
      click_button "save"
      # index
      response.should contain("hoge")
      click_link "hoge"
      # show -> update
      fill_in "item[content]", :with => "hoge updated"
      click_button "save"
      # index
      response.should contain("hoge updated")
    end
  end
end
