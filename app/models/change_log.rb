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
      record_klass = self.record_type.camelcase.constantize #.where(:user_id => self.user_id)
      # TODO: it must be better to use unscoped rails3beta5 or later
      # NOTE: exclusive scope is needed (e.g. asynchronous done of listing on both server and celint)
      record_klass.send(:with_exclusive_scope) do
        self.record ||= record_klass.where(:user_id => self.user_id).find_duplication(change) || record_klass.new(:user_id => self.user_id)
      end
      self.record.no_auto_log = true
      if self.record.new_record?
        self.record.update_attributes!(change)
        #log = record.log!(self.json)
        save!
      else
        save!
        #log = record.log!(self.json)
        # It is possible that a client post older changes than server's. Overwriting the record with
        # that change may revert the record. So, let's merge the change with newer changes.
        record.change_logs.where("changed_at >= ?", self.changed_at).except(:order).order("changed_at ASC").all.each do |l|
          change = change.merge(ActiveSupport::JSON.decode(l.json))
        end
        record.update_attributes!(change)
      end
    end
    true
  rescue ActiveRecord::RecordNotSaved
    false
  end
  
  before_create do
    self.user_id ||= self.record.user_id
    self.changed_at ||= ActiveSupport::JSON.decode(self.json)["updated_at"]
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
          # if the reocrd (self) belongs to possible new records, those record must be logged beforehand.
          ((self.class.class_variable_defined?("@@log_dependencies") && self.class.class_variable_get("@@log_dependencies")) || []).each do |name|
            dep = self.send(name)
            if dep.changed?
              dep.log!
              dep.no_auto_log = true
            end
          end
          
          self.log!
        end
        self.no_auto_log = nil
      end
      # NOTE: should do auto recognizing from association?
      def base.log_dependency(*args)
        self.class_variable_set("@@log_dependencies", args)
      end
      unless base.method_defined?(:find_duplication)
        def base.find_duplication(attrs)
          nil # overwrite this method if the model wants to control duplication
        end
      end
    end
    
    def log!(json_or_value=nil)
      case json_or_value
      when String
        json = json_or_value
      when Hash, nil
        c = json_or_value || self.attributes.slice(*self.changed)
        jsonValue = c.merge(c){|k, v| v.as_json }
        json = jsonValue.to_json
      end
      ChangeLog.create!(:record => self, :json => json)
#       change = ActiveSupport::JSON.decode(json)
#       ChangeLog.create!(:record => self, :json => json, :user_id => self.user_id, :changed_at => change["updated_at"])
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
