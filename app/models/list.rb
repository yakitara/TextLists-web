class List < ActiveRecord::Base
  INBOX = "in-box"
#  default_scope :order => "lists.position ASC, lists.created_at DESC"
  
  belongs_to :user
  has_many :listings, :dependent => :destroy, :conditions => {:deleted_at => nil}, :order => "listings.position ASC, listings.created_at DESC", :inverse_of => :list
  # NOTE: default_scope on Listing doesn't seem to affect here
  has_many :items, :through => :listings, :conditions => "listings.deleted_at IS NULL", :order => "listings.position ASC, listings.created_at DESC"
  
  validates :name, :presence => true
  
  include UserScope, HalfAutoTimestamp, ChangeLog::Logger

  def self.find_duplication(attrs)
    self.find_by_name(attrs["name"])
  end
end
