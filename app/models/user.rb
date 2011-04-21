class User < ActiveRecord::Base
  has_many :credentials
  has_many :lists
  has_many :items
  has_many :listings
  has_many :change_logs
  
  def inbox!
    self.lists.find_by_name(List::INBOX) || self.lists.create!(:name => List::INBOX)
  end
  
  before_save do
    if self.salt.blank?
      require "digest/sha2"
      self.salt = SecureRandom.hex(32)
    end
  end
  
  after_create do
    self.inbox!
  end
end
