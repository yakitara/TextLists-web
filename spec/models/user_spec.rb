require 'spec_helper'

describe User do
  describe "#create" do
    before(:each) do
      @user = User.create
    end
    
    it { @user.should have(1).lists }
    it "has in-box" do
      @user.lists.find_by_name(List::INBOX).should be_true
    end
  end
end
