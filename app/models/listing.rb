class Listing < ActiveRecord::Base
  default_scope :conditions => {:deleted_at => nil}, :order => "position ASC, created_at DESC"
#   def self.without_default_scope(&block)
#     self.with_exclusive_scope(&block)
#   end
  # 2010-07-20: inverse_of has_many associations causes an error on fields_for
  # undefined method `set_item_target' for #<Listing:0xe2fb30>
  # Also, there is a note on that in activerecord-3.0.0.beta4/lib/active_record/associations/belongs_to_association.rb .
  #   NOTE - for now, we're only supporting inverse setting from belongs_to back onto
  #   has_one associations.
  belongs_to :list #, :inverse_of => :listings
  belongs_to :item #, :inverse_of => :listings
  belongs_to :user #, :inverse_of => :listings
  
  def done!
    update_attributes!(:deleted_at => Time.now)
  end
  
  include UserScope, HalfAutoTimestamp, ChangeLog::Logger
  # to avoid logging item after the log of listing
  log_dependency :item
end
