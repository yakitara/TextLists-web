require 'spec_helper'

describe ChangeLog do
  #pending "add some examples to (or delete) #{__FILE__}"
  describe "recorded after save. json column of last log" do
    before do
      @list = List.create!(:name => "foo", :user_id => 1)
      @list.position = 3
      @list.save
      @log = ChangeLog.last
    end
    context "position" do
      subject { ActiveSupport::JSON.decode(@log.json)["position"] }
      it { should == 3 }
    end
  end
end
