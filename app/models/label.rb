class Label < ActiveRecord::Base
  default_scope order("labels.position ASC, labels.created_at DESC")
  belongs_to :list
  belongs_to :user

  def done!
    self.update_attributes!(:deleted_at => Time.now)
  end
end
