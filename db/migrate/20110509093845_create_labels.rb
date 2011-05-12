class CreateLabels < ActiveRecord::Migration
  def self.up
    create_table :labels do |t|
      t.integer :user_id, :null => false
      t.integer :list_id, :null => false
      t.integer :position, :null => false, :default => 0
      t.string :name, :null => false, :limit => 20
      t.string :color, :null => false, :limit => 6
      t.datetime :deleted_at
      t.timestamps
    end

    create_table :labelings do |t|
      t.integer :user_id, :null => false
      t.integer :label_id, :null => false
      t.integer :item_id, :null => false
      t.datetime :deleted_at
      t.timestamps
    end
    add_index :labelings, [:label_id, :item_id], :unique => true
  end

  def self.down
    drop_table :labelings;
    drop_table :labels;
  end
end
