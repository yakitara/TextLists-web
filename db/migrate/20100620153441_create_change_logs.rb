class CreateChangeLogs < ActiveRecord::Migration
  def self.up
    create_table :change_logs do |t|
      t.text :json, :null => false
      t.string :record_type, :null => false
      t.integer :record_id, :null => false
      t.integer :user_id, :null => false
      t.datetime :changed_at, :null => false
      t.datetime :created_at, :null => false
    end
    add_index :change_logs, [:record_type, :record_id]
  end

  def self.down
    drop_table :change_logs
  end
end
