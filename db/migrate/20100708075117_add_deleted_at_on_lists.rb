class AddDeletedAtOnLists < ActiveRecord::Migration
  def self.up
    change_table :lists do |t|
      t.datetime :deleted_at
    end
  end

  def self.down
    change_table :lists do |t|
      t.remove :deleted_at
    end
  end
end
