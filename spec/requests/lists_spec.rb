require 'spec_helper'

describe "Lists" do
  include RequestsSupport
  
  before(:each) do
    create_login_session
  end
  
  describe "new -> create -> show -> update -> destroy" do
    it "works!" do
      visit new_list_path
      #response.should be_success
      
      fill_in "list[name]", :with => "foo"
      click_button "save"
      #response.should contain("foo")
      page.should have_content("foo")
      
      fill_in "list[name]", :with => "foo updated"
      click_button "save"
      #response.should contain("foo updated")
      page.should have_content("foo updated")
      
      click_link "delete this list"
      page.should_not have_content("foo updated")
    end
  end
  
  describe "delete a list doesn't delete the list nor associated listings" do
    before(:each) do
      @list = @current_user.lists.create!(:name => "list")
      @listing = @current_user.listings.create!(:list => @list, :item => @current_user.items.create!(:content => "item"))
      # delete list_path(@list)
      visit list_path(@list)
      click_link "delete this list"

      @list = List.unscoped.find(@list)
      @listing = Listing.unscoped.find(@listing)
    end
    it { @list.deleted_at.should_not be_nil }
    it { @listing.deleted_at.should_not be_nil }
  end
end
