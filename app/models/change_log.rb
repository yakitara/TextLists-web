# The basic rule is simple:
# 1. Sotre any change logs of clients and the server into the server.
# 2. In ASC sequential order of change_logs.id, apply any unapplied logs to records.
#   - If any newer changed_at logs are available, the change of the current log is going to be merged with them)
class ChangeLog < ActiveRecord::Base
  include UserScope
  
  belongs_to :record, :polymorphic => true
  default_scope :order => "id ASC"
  
#   def as_json(options=nil)
#     returning(self.attributes) do |value|
#       value["change"] = ActiveSupport::JSON.decode(value.delete("json"))
#     end
#   end
  
  # return already accepted log or new one
  def self.recognize(attrs)
    self.where(attrs.reject{|k,v|v.nil?}).first or self.new(attrs)
  end
  
  def accept
    return true unless self.new_record?
    
    change = ActiveSupport::JSON.decode(self.json)
    transaction do
      record = self.record_id ? self.record : (self.record = self.record_type.camelcase.constantize.new(:user_id => self.user_id))
      record.no_auto_log = true
      if record.new_record?
        record.update_attributes!(change)
        log = record.log!(self.json)
      else
        log = record.log!(self.json)
        # It is possible that a client post older changes than server's. Overwriting the record with
        # that change may revert the record. So, let's merge the change with newer changes.
        record.change_logs.where("changed_at >= ?", log.changed_at).all.each do |l|
          change = change.merge(ActiveSupport::JSON.decode(l.json))
        end
        record.update_attributes!(change)
      end
    end
    true
  rescue ActiveRecord::RecordNotSaved
    false
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
          change = self.attributes.slice(*self.changed)
          jsonValue = change.merge(change){|k, v| v.as_json }
          self.log!(jsonValue.to_json)
        end
        self.no_auto_log = nil
      end
    end
    
    def log!(json)
      #jsonValue = change.merge(change){|k, v| v.as_json }
      change = ActiveSupport::JSON.decode(json)
      ChangeLog.create!(:record => self, :json => json, :user_id => self.user_id, :changed_at => change["updated_at"])
    end
=begin    
    def merge(change)
      change = ActiveSupport::JSON.decode(change) if change.is_a?(String)
      transaction do
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
#     rescue ActiveRecord::RecordNotUnique => e
#       # this rescue can't help because there are no way to replace the record with unique one... any?
    end
=end
  end
end
