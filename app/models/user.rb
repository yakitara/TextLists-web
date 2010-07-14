class User < ActiveRecord::Base
  has_many :credentials
  has_many :lists
  has_many :items
  has_many :listings
  
  def inbox!
    self.lists.find_by_name(List::INBOX) || self.lists.create!(:name => List::INBOX)
  end
  
  before_save do
    if self.salt.blank?
      require "digest/sha2"
      self.salt = Digest::SHA2.hexdigest("#{self.hash}-#{Time.now}")
    end
  end
  
  after_create do
    self.inbox!
  end
end
