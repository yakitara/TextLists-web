class List < ActiveRecord::Base
  INBOX = "in-box"
  
  belongs_to :user
  has_many :listings, :dependent => :destroy, :order => "listings.position ASC"
  # NOTE: default_scope on Listing doesn't seem to affect here
  has_many :items, :through => :listings, :conditions => "listings.deleted_at IS NULL"
  
  validates :name, :presence => true
  
  include UserScope
end
