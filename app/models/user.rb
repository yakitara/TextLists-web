class User < ActiveRecord::Base
  has_many :credentials
  
  before_save do
    if self.salt.blank?
      require "digest/sha2"
      self.salt = Digest::SHA2.hexdigest("#{self.hash}-#{Time.now}")
    end
  end
end
