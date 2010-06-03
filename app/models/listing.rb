class Listing < ActiveRecord::Base
  default_scope :conditions => {:deleted_at => nil}, :order => "position ASC, created_at DESC"
  belongs_to :list
  belongs_to :item
  belongs_to :user
  
  include UserScope

  def done!
    update_attributes!(:deleted_at => Time.now)
  end
end
