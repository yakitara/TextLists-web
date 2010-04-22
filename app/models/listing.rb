class Listing < ActiveRecord::Base
  default_scope :conditions => {:deleted_at => nil}
  belongs_to :list
  belongs_to :item

  include UserScope
end
