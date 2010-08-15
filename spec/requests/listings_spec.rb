require 'spec_helper'

describe "Listings" do
  include RequestsSupport
  
  before(:each) do
    create_login_session
    @list = @current_user.lists.create!(:name => "list a")
    @item = @current_user.items.create!(:content => "hoge")
    @listing = @list.listings.create!(:item => @item, :user => @current_user, :position => 3)
  end
  
  describe "Done" do
    # TODO: from each index and show, but they are ujs link which aren't yet supported by webrat
    it "works" do
      delete list_item_listing_path(@list, @item, @listing)
      response.should_not contain("hoge")
      @list.should have(0).item
    end
    
    it "should work with xhr" do
      pending
    end
  end

  describe "Undone" do
    before do
      @listing.done!
    end
    
    it "works" do
      put undone_item_listing_path(@item, @listing)
      response.should_not contain("hoge")
      @list.should have(1).item
    end
    
    it "should work with xhr" do
      pending
    end
  end
  
  describe "Move to another list" do
    before(:each) do
      @list_b = @current_user.lists.create!(:name => "list b")
      post move_list_item_listings_path(@list, @item), :listing => {:list_id => @list_b.id}
    end
    
    it "works" do
      @list.should   have(0).items
      @list_b.should have(1).items
    end
    
    it "position should reset to 0" do
      @item.listings.where(:list_id => @list_b.id).first.position.should == 0
    end
  end
end
