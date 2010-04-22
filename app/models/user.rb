class User < ActiveRecord::Base
  has_many :credentials
end
