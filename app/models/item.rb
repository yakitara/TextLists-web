class Item < ActiveRecord::Base
  has_many :listings, :dependent => :destroy
  has_many :lists, :through => :listings
  
  accepts_nested_attributes_for :listings
  
  validates :content, :presence => true
end
