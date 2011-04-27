require 'spec_helper'

describe "Items" do
  include RequestsSupport
  
  before(:each) do
    create_login_session("taro")
  end
  
  context "#index" do
    before(:each) do
      @list = @current_user.lists.create!(:name => "a list")
    end
    
    def create_item(attrs)
      @current_user.items.create!(attrs).tap do |item|
        @list.listings.create!(:item => item, :user => @current_user)
      end
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
      @item = create_item(:content => "should be done")
      
      visit list_items_path(@list.id)
      
      item_selector = "div.items div.item#item_#{@item.id}"
      within(item_selector) do
        find(".title").should have_content("should be done")
        click_on "done"
      end
      page.should have_no_selector(item_selector)
    end
    
    it "moves to another list", :js => true do
      @current_user.lists.create!(:name => "another list")
      @item = create_item(:content => "should be moved")
      
      visit list_items_path(@list.id)
      
      item_selector = "div.items div.item#item_#{@item.id}"
      within(item_selector) do
        find(".title").should have_content("should be moved")
        select "another list", :from => "listing[list_id]"
        #click_on "move"
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
  
  describe "#done" do
    before do
      visit done_items_path
    end
    describe "undone", :js => true do
      before do
        @selector = ".items .item##{dom_id(items(:done_item))}"
        within(@selector) do
          click_on "undone"
        end
      end
      subject { page }
      it { should_not have_selector(@selector) }
    end
  end
end
