#require "active_support/json"

class ChangeLog < ActiveRecord::Base
  belongs_to :record, :polymorphic => true
  default_scope :order => "id ASC"

  module Recorder
    def self.included(base)
      base.after_save do
# NOTE: to avoid following error, when a hash has Time value, call each as_json before the hash to_json
# ArgumentError: wrong number of arguments (2 for 1)
# from /usr/local/rvm/gems/ruby-1.9.2-preview3/gems/activesupport-3.0.0.beta4/lib/active_support/json/encoding.rb:133:in `to_json'
        jsonValue = self.attributes.slice(*self.changed)
        jsonValue.merge!(jsonValue){|k,v| v.as_json }
        ChangeLog.create!(:record => self, :json => jsonValue.to_json, :user_id => self.user_id)
      end
    end
  end
end
