module HalfAutoTimestamp
  def self.included(base)
    base.record_timestamps = false
    base.before_save do
      unless self.updated_at_changed?
        write_attribute(:updated_at, current_time_from_proper_timezone)
      end
    end
    base.before_create do
      unless self.created_at_changed?
        write_attribute(:created_at, current_time_from_proper_timezone)
      end
    end
  end
end
