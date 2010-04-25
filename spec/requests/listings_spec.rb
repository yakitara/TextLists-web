require 'spec_helper'

describe "Listings" do
  include RequestsSupport
  
  before(:each) do
    create_login_session
    @list = @current_user.lists.create!(:name => "foo")
    @item = @current_user.items.create!(:content => "hoge")
    @listing = @list.listings.create!(:item => @item, :user => @current_user)
  end
  
  describe "Done" do
    # TODO: from each index and show, but they are ujs link which aren't yet supported by webrat
    it "works" do
      delete list_item_listing_path(@list, @item, @listing)
      response.should_not contain("hoge")
      @list.should have(0).items
    end
  end
  
  describe "Move to another list" do
    before(:each) do
      @list_b = @current_user.lists.create!(:name => "bar")
    end
    
    it "works" do
      post move_list_item_listings_path(@list, @item), :listing => {:list_id => @list_b.id}
      
      @list.should   have(0).items
      @list_b.should have(1).items
    end
  end
end
