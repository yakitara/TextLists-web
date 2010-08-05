class Item < ActiveRecord::Base
  default_scope :order => "created_at DESC"
  
  belongs_to :user
  has_many :listings, :dependent => :destroy, :inverse_of => :item
  has_many :lists, :through => :listings
  
  accepts_nested_attributes_for :listings
  
  cattr_reader :content_max_length
  # NOTE: ":presence => true" cause inconsistent with current CoreData validation
  validates :content, :length => {:within => 1..4000}
  
  include UserScope, HalfAutoTimestamp, ChangeLog::Logger
end
