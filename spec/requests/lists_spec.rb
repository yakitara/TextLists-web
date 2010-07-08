require 'spec_helper'

describe "Lists" do
  include RequestsSupport
  
  before(:each) do
    create_login_session
  end
  
  describe "new -> create -> show -> update -> destroy" do
    it "works!" do
      get new_list_path
      response.should be_success
      
      fill_in "list[name]", :with => "foo"
      click_button "save"
      response.should contain("foo")
      
      fill_in "list[name]", :with => "foo updated"
      click_button "save"
      response.should contain("foo updated")
      
      # NOTE: webrat doesn't seem to know about ujs
      # click_link "delete this list"
      # FIXME: should popup confirm dialog
      
      list = @current_user.lists.first
      delete list_path(list)
      response.should_not contain("foo updated")
    end
  end
  
  describe "delete a list doesn't delete the list nor associated listings" do
    before(:each) do
      @list = @current_user.lists.create!(:name => "list")
      @listing = @current_user.listings.create!(:list => @list, :item => @current_user.items.create!(:content => "item"))
      delete list_path(@list)
      @list = List.unscoped.find(@list)
      @listing = Listing.unscoped.find(@listing)
    end
    it { @list.deleted_at.should_not be_nil }
    it { @listing.deleted_at.should_not be_nil }
  end
  
  describe "xhr GET /lists/:id/sort" do
    it "works"
  end
end
