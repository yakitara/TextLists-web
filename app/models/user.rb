class User < ActiveRecord::Base
  has_many :credentials
  has_many :lists
  has_many :items
  has_many :listings
  
  before_save do
    if self.salt.blank?
      require "digest/sha2"
      self.salt = Digest::SHA2.hexdigest("#{self.hash}-#{Time.now}")
    end
  end
  
  after_create do
    if self.lists.blank?
      self.lists.create!(:name => List::INBOX)
    end
  end
end
