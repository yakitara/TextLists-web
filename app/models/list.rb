class List < ActiveRecord::Base
  has_many :listings
  has_many :items, :through => :listings
end
