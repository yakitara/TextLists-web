# At the time of Rails 3.0.0 beta 4,
# In active_support/json/encoding.rb and active_support/time_with_zone.rb, 
# if ActiveSupport.use_standard_json_time_format is true,
# {time like class}#as_json uses DateTime#xmlschema (in active_support/core_ext/date_time/conversions.rb)
# This may return "2010-07-06T08:47:46+09:00" kind of formated string for a local time, but NSDateFormatter
# in iOS 4.0 doesn't seem to have format characters which can recognize +09:00 (with colon).
# That is said that +09:00 is not unicode standard format...
# So just omit colon.

require "active_support/json"
[DateTime, Time, ActiveSupport::TimeWithZone].each do |klass|
  klass.class_eval do
    def as_json(options = nil) #:nodoc:
      utc.strftime("%Y-%m-%dT%H:%M:%S%z")
    end
  end
end
