class List < ActiveRecord::Base
  belongs_to :user
  has_many :listings, :dependent => :destroy
  has_many :items, :through => :listings
  
  validates :name, :presence => true
  
  include UserScope
end
