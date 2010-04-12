class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter do
    @lists = List.joins("LEFT JOIN listings ON listings.list_id = lists.id").group("lists.id")
    @lists = @lists.all(:select => "lists.*, COUNT(listings.id) AS item_count")
  end
end
