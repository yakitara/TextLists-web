class Labeling < ActiveRecord::Base
  include Done

  belongs_to :user
  belongs_to :label
  belongs_to :item
end
