# to avoid:
# ActiveRecord::StatementInvalid (PGError: ERROR:  index row size 2784 exceeds maximum 2712 for index "change_logs_unique"HINT:  Values larger than 1/3 of a buffer page cannot be indexed.
# Consider a function index of an MD5 hash of the value, or use full text indexing.
class DropChangeLogsUniqueIndex < ActiveRecord::Migration
  def self.up
    remove_index "change_logs", :name => "change_logs_unique"
    #execute "CREATE UNIQUE INDEX change_logs_unique ON change_logs USING hash (user_id, record_type, record_id, json)"
  end

  def self.down
    #remove_index "change_logs", "change_logs_unique"
    add_index :change_logs, [:user_id, :record_type, :record_id, :json], :unique => true, :name => "change_logs_unique"
  end
end
