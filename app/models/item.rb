class Item < ActiveRecord::Base
  #default_scope :order => "items.created_at DESC"
  
  belongs_to :user
  
  has_many :listings, :dependent => :destroy, :inverse_of => :item
  has_many :lists, :through => :listings
  
  has_many :labelings, :dependent => :destroy, :conditions => {:deleted_at => nil}
  has_many :labels, :through => :labelings
  
  accepts_nested_attributes_for :listings
  
  cattr_reader :content_max_length
  # NOTE: ":presence => true" cause inconsistent with current CoreData validation
  validates :content, :length => {:within => 1..4000}
  
  include UserScope, HalfAutoTimestamp, ChangeLog::Logger
  
  def title
    self.content[/(.*)\n?/,0]
  end

  def move!(from_list, to_list)
    self.class.transaction do
      listing = self.listings.where(:list_id => from_list.id).first
      listing.list = to_list
      listing.save!
      self.labelings.each{|l| l.done! }
    end
  end
end
