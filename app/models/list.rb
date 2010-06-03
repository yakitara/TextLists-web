class List < ActiveRecord::Base
  INBOX = "in-box"
#  default_scope :order => "lists.position ASC, lists.created_at DESC"
  
  belongs_to :user
  has_many :listings, :dependent => :destroy, :order => "listings.position ASC"
  # NOTE: default_scope on Listing doesn't seem to affect here
  has_many :items, :through => :listings, :conditions => "listings.deleted_at IS NULL", :order => "listings.position ASC, listings.created_at DESC"
  
  validates :name, :presence => true
 
  before_create do
    self.position = 999
    # The magic number 999 must be same as lists created at iphone app.
  end


  include UserScope
end
