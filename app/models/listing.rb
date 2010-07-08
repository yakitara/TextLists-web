class Listing < ActiveRecord::Base
  default_scope :conditions => {:deleted_at => nil}, :order => "position ASC, created_at DESC"
#   def self.without_default_scope(&block)
#     self.with_exclusive_scope(&block)
#   end
  belongs_to :list, :inverse_of => :listings
  belongs_to :item, :inverse_of => :listings
  belongs_to :user, :inverse_of => :listings
  
  def done!
    update_attributes!(:deleted_at => Time.now)
  end
  
  include UserScope, HalfAutoTimestamp, ChangeLog::Logger
  # to avoid logging item after the log of listing
  log_dependency :item
end
