require 'spec_helper'

describe Item do
  fixtures :users
  
  context "updated continuously by autosave" do
    it "merges change logs" do
      @item = users(:taro).items.create!(:content => "created")
      @item.update_attributes!(:content => "updated")
      @item.should have(2).change_logs
      @item.update_attributes!(:content => "updated again")
      @item.reload
      @item.should have(2).change_logs
      @item.change_logs.last.decoded["content"].should == "updated again"
    end
  end

  context "updated after other other record's changelog" do
    it "doesn't marge change logs"
  end
end
