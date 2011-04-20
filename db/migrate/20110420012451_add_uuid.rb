class AddUuid < ActiveRecord::Migration
  def self.up
    [:lists, :items, :listings].each do |t|
      add_column t, :uuid, :string, :limit => 36
    end
  end

  def self.down
    [:lists, :items, :listings].each do |t|
      remove_column t, :uuid
    end
  end
end
