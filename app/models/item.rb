class Item < ActiveRecord::Base
  belongs_to :user
  has_many :listings, :dependent => :destroy
  has_many :lists, :through => :listings
  
  accepts_nested_attributes_for :listings
  
  validates :content, :presence => true
  
  include UserScope
end
