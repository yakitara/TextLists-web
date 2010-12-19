require 'spec_helper'

describe "Items" do
  include RequestsSupport
  
  before(:each) do
    create_login_session
  end
  
  describe "new -> create -> update" do
    it "works" do
      @list = @current_user.lists.create!(:name => "foo")
      
      #get list_items_path(@list.id)
      #response.should be_success
      visit list_items_path(@list.id)

      click_link "new item"
      # new -> create
      fill_in "item[content]", :with => "hoge"
      click_button "save"
      # index
      # response.should contain("hoge")
      page.should have_content("hoge")
      
      click_link "hoge"
      # show -> update
      fill_in "item[content]", :with => "hoge updated"
      click_button "save"
      # index
      # response.should contain("hoge updated")
      page.should have_content("hoge updated")
    end
  end
  
  describe "done list" do
    it "works" do
      pending
#       get done_items_path
#       response.should be_success
    end
  end
end
