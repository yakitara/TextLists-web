require 'spec_helper'

describe "Lists" do
  before(:all) do
    
  end

  describe "GET /lists/new" do
    it "works!" do
      get new_list_path
      response.should be_success
    end
  end
end
