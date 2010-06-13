module HalfAutoTimestamp
  def self.included(base)
    base.record_timestamps = false
    base.before_save do
      self.touch(:updated_at) unless self.updated_at_changed?
    end
    base.before_create do
      self.touch(:created_at) unless self.created_at_changed?
    end
  end
end
