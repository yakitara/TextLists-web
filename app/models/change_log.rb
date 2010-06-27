# The basic rule is simple:
# 1. Sotre any change logs of clients and the server into the server.
# 2. In ASC sequential order of change_logs.id, apply any unapplied logs to records.
#   - If any newer changed_at logs are available, the change of the current log is going to be merged with them)
class ChangeLog < ActiveRecord::Base
  include UserScope
  
  belongs_to :record, :polymorphic => true
  default_scope :order => "id ASC"
  
  def as_json(options=nil)
    returning(self.attributes) do |value|
      value["change"] = ActiveSupport::JSON.decode(value.delete("json"))
    end
  end
  
  module Logger
    def self.included(base)
      base.send(:attr_accessor, :no_auto_log)
      base.send(:has_many, :change_logs, :as => :record, :order => "changed_at ASC")
      base.after_save do
# NOTE: to avoid following error, when a hash has Time value, call each as_json before the hash to_json
# ArgumentError: wrong number of arguments (2 for 1)
# from /usr/local/rvm/gems/ruby-1.9.2-preview3/gems/activesupport-3.0.0.beta4/lib/active_support/json/encoding.rb:133:in `to_json'
        unless self.no_auto_log
          self.log!(self.attributes.slice(*self.changed))
        end
        self.no_auto_log = nil
      end
    end
    
    def log!(change)
      jsonValue = change.merge(change){|k, v| v.as_json }
      ChangeLog.create!(:record => self, :json => jsonValue.to_json, :user_id => self.user_id, :changed_at => change["updated_at"])
    end
    
    def merge(change)
      unless self.new_record?
        self.log!(change)
        # It is possible that a client post older changes than server's. Overwriting the record with
        # that change may revert the record. So, let's merge the change with newer changes.
        self.change_logs.where("changed_at >= ?", change[:updated_at]).all.each do |log|
          change = change.merge(ActiveSupport::JSON.decode(log.json))
        end
        self.no_auto_log = true
      end
      self.update_attributes(change)
    end
  end
end
