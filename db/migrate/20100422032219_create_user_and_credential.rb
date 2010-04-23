class CreateUserAndCredential < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :salt, :null => false
      t.timestamps
    end
    add_index :users, :salt, :unique => true
    
    create_table :credentials do |t|
      t.integer :user_id, :null => false
      t.string :identifier, :null => false
      t.timestamps
    end
    add_index :credentials, :identifier, :unique => true

    %w(items lists listings).each do |table|
      add_column table, :user_id, :integer, :null => false, :default => 0
      change_column_default table, :user_id, nil
    end
  end

  def self.down
    drop_table :users
    drop_table :credentials
    remove_column :items, :user_id
    remove_column :lists, :user_id
    remove_column :listings, :user_id
  end
end
