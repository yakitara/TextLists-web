class InitialSchema < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.text :content, :null => false
      t.timestamps
    end
    
    create_table :lists do |t|
      t.string :name, :null => false
      t.integer :position
      t.timestamps
    end
    
    create_table :listings do |t|
      t.integer :list_id, :null => false
      t.integer :item_id, :null => false
      t.integer :position
      t.datetime :deleted_at
      t.timestamps
    end
    add_index :listings, [:list_id, :item_id], :unique => true
  end

  def self.down
    drop_table :listings
    drop_table :lists
    drop_table :items
  end
end
