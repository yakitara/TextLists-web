require 'spec_helper'

describe "Items" do
  include RequestsSupport
  
  before(:each) do
    create_login_session
  end
  
  context "#index" do
    before(:each) do
      @list = @current_user.lists.create!(:name => "foo")
    end
    
    it "prepends a new item", :js => true do
      visit list_items_path(@list.id)
      within "form.new_item" do
        fill_in 'item[content]', :with => "new item!"
        click_on "create item"
      end
      find("div.items div.item:first-child .title").should have_content("new item!")
    end

    it "gets done", :js => true do
      @item = Item.create!(:content => "should get done", :user => @current_user)
      @list.listings.create!(:item => @item, :user => @current_user)
      visit list_items_path(@list.id)
      item_selector = "div.items div.item#item_#{@item.id}"
      within(item_selector) do
        find(".title").should have_content("should get done")
        click_on "done"
      end
      page.should have_no_selector(item_selector)
    end

    it "sorts items" # it semms to be difficult to do even with drag_to
  end
  
  # describe "new -> create -> update" do
  #   it "works" do
  #     @list = @current_user.lists.create!(:name => "foo")
      
  #     #get list_items_path(@list.id)
  #     #response.should be_success
  #     visit list_items_path(@list.id)

  #     click_link "new item"
  #     # new -> create
  #     fill_in "item[content]", :with => "hoge"
  #     click_button "save"
  #     # index
  #     # response.should contain("hoge")
  #     page.should have_content("hoge")
      
  #     click_link "hoge"
  #     # show -> update
  #     fill_in "item[content]", :with => "hoge updated"
  #     click_button "save"
  #     # index
  #     # response.should contain("hoge updated")
  #     page.should have_content("hoge updated")
  #   end
  # end
  
#   describe "done list" do
#     it "works" do
#       pending
# #       get done_items_path
# #       response.should be_success
#     end
#   end
end
