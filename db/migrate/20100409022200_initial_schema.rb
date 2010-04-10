class InitialSchema < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.text :content, :null => false
      t.timestamps
    end
    
    create_table :lists do |t|
      t.string :name, :null => false
      t.timestamps
    end
    
    create_table :listings do |t|
      t.integer :list_id, :null => false
      t.integer :item_id, :null => false
      t.datetime :deleted_at
      t.timestamps
    end
  end

  def self.down
    drop_table :listings
    drop_table :lists
    drop_table :items
  end
end
