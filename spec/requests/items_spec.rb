require 'spec_helper'

describe "Items" do
  include RequestsSupport
  
  before(:each) do
    create_login_session("taro")
  end
  
  context "#index" do
    before(:each) do
      @list = lists(:list_a)
    end
    
    def create_item(attrs)
      @current_user.items.create!(attrs).tap do |item|
        @list.listings.create!(:item => item, :user => @current_user, :position => 1)
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
    
    describe "moves to another list", :js => true do
      before do
        @to_list = @current_user.lists.create!(:name => "another list")
        @item = create_item(:content => "should be moved")
        @item.listings.where(:list_id => @list.id).first.position.should_not == 0
        @item.labelings.create!(:label => labels(:red_label), :user => @current_user)
        @item.labelings.should_not have(0).items
        
        visit list_items_path(@list.id)
        
        @item_selector = "div.items div.item#item_#{@item.id}"
        within(@item_selector) do
          find(".title").should have_content("should be moved")
          select "another list", :from => "listing[list_id]"
        end
      end
      
      it { page.should_not have_selector(@item_selector) }

      describe "moved item" do
        before do
          @item = @item.reload
        end
        describe "listing" do
          subject { @item.listings.where(:list_id => @to_list.id).first }
          its(:position) { should == 0 }
        end
        it { @item.labelings.should have(0).labels }
      end
    end
    
    it "sorts items" # it semms to be difficult to do even with drag_to
  end

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
