class List < ActiveRecord::Base
  INBOX = "in-box"
  default_scope :conditions => {:deleted_at => nil}, :order => "lists.position ASC, lists.created_at DESC"
  
  belongs_to :user
  has_many :listings, :dependent => :destroy, :order => "listings.position ASC, listings.created_at DESC", :inverse_of => :list
  # NOTE: default_scope on Listing doesn't seem to affect here
  has_many :items, :through => :listings, :conditions => "listings.deleted_at IS NULL", :order => "listings.position ASC, listings.created_at DESC"
  
  def done!
    transaction do
      self.update_attributes!(:deleted_at => Time.now)
      self.listings.each do |listing|
        listing.done!
      end
    end
  end
  
  # NOTE: ":presence => true" cause inconsistent with current CoreData validation
  validates :name, :length => {:within => 1..20}
  
  include UserScope, HalfAutoTimestamp, ChangeLog::Logger

  def self.find_duplication(attrs)
    self.find_by_name(attrs["name"])
  end
end
