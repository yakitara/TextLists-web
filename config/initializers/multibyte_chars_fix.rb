# https://rails.lighthouseapp.com/projects/8994/tickets/4822-rails3-beta4-ruby-19
# http://github.com/rails/rails/commit/cfc9439454988a07451a7e261379569d135bcef5
if Rails.version == "3.0.0.beta4"
  begin
    require "active_support/multibyte/chars"
  rescue => e
    ActiveSupport::Multibyte::Chars.class_eval do
      def <=>(other)
        @wrapped_string <=> other
      end
    end
#     module ActiveSupport
#       module Multibyte
#         class Chars
#           def <=>(other)
#             @wrapped_string <=> other
#           end
#         end
#       end
#     end
    retry
  end
#  require "active_support/multibyte/chars"
else
  puts "warning: #{__FILE__} must be no use."
end
