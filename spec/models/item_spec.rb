require 'spec_helper'

describe Item do
  fixtures :users
  
  context "update an item continuously by autosave" do
    before do
      Timecop.freeze(2.minute.ago) do
        @item = users(:taro).items.create!(:content => "created")
      end
      Timecop.freeze(1.minute.ago) do
        @item.update_attributes!(:content => "updated")
      end
      @item.should have(2).change_logs
      @item.update_attributes!(:content => "updated again")
      @item.reload
    end
    describe "doesn't create new change_log" do
      subject { @item }
      it { should have(2).change_logs }
    end
    describe "last change_log of the updated item" do
      subject { @item.change_logs.last }
      it { subject.decoded["content"].should == "updated again" }
      it { subject.changed_at.should be > subject.created_at }
    end
  end

  context "updated after other other record's changelog" do
    it "doesn't marge change logs"
  end
end
