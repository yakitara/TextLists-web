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
    #add_index :change_logs, [:record_type, :record_id]
    # NOTE: some configuration of PostgreSQL may fail with the message: "Input string is longer than NAMEDATALEN-1 (63)"
    # NOTE: automatic index name may be too long, so name as is.
    add_index :change_logs, [:user_id, :record_type, :record_id, :json], :unique => true, :name => "change_logs_unique"
  end

  def self.down
    drop_table :change_logs
  end
end
