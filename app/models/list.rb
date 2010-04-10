class List < ActiveRecord::Base
  has_many :listings
  has_many :items, :through => :listings
  
  validates :name, :presence => true
end
