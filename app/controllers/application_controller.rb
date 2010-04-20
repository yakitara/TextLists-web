class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter do
    selects = "lists.id, lists.name, lists.position" # for PostgreSQL
    @lists = List.joins("LEFT JOIN listings ON listings.list_id = lists.id").group(selects)
    @lists = @lists.order("lists.position ASC").all(:select => "#{selects}, COUNT(listings.id) AS item_count")
  end
end
