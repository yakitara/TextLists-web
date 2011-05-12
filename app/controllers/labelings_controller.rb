class LabelingsController < ApplicationController
  before_filter do
    @list = current_user.lists.find(params[:list_id])
    @item = @list.items.find(params[:item_id])
    @label = @list.labels.find(params[:label_id])
  end

  def create
    # NOTE: not use @item.labelings to avoid "deleted_at IS NULL"
    labelings = Labeling.where(:item_id => @item.id, :label_id => @label.id, :user_id => current_user.id)
    if @labeling = labelings.first
      @labeling.update_attributes!(:deleted_at => nil)
    else
      labelings.create!
    end
    respond_to do |format|
      format.html { render :partial => "/items/label", :locals => { :label => @label } }
    end
  end

  def destroy
    @rabeling = @item.labelings.where(:label_id => @label.id).first
    @rabeling.done!
    render :json => {:label_id => @label.id}
  end
end
