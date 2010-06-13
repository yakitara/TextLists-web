class Item < ActiveRecord::Base
  default_scope :order => "created_at DESC"
  
  belongs_to :user
  has_many :listings, :dependent => :destroy
  has_many :lists, :through => :listings
  
  accepts_nested_attributes_for :listings
  
  validates :content, :presence => true
  
  include UserScope, HalfAutoTimestamp
  # don't autotimestamp if timestamps are explicitly given
#   record_timestamps = false
#   before_save do
#     self.touch(:updated_at) unless self.updated_at_changed?
#   end
#   before_create do
#     self.touch(:created_at) unless self.created_at_changed?
#   end
end
