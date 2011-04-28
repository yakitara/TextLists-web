# -*- coding: utf-8 -*-
# 2010-07-04: hiroshi3110@gmail.com, http://github.com/hiroshi
# I wrote this for Rails 3 beta 4 / Ruby 1.9.2-pre3.
# This is a VERY nasty patch for work arounding rack's Encoding::BINARY (ASCII-8BIT) rack.input issue.
# I don't know the RIGHT solution about the issue, but I have to fix:
#   Encoding::UndefinedConversionError ("\xE3" from ASCII-8BIT to UTF-8)
# Sometime in the future, I hope this is no use...
# References:
# wycats pointed at "Where it doesn’t work" in http://yehudakatz.com/2010/05/17/encodings-unabridged/
ActionDispatch::Http::Parameters.module_eval do
  private
  def normalize_parameters_with_force_encoding_to_utf8(value)
    case value
    when Hash, Array, nil
    else
      value = value.force_encoding("UTF-8")
    end
    normalize_parameters_without_force_encoding_to_utf8(value)
  end
  alias_method_chain :normalize_parameters, :force_encoding_to_utf8
end
