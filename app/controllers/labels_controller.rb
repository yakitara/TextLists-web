class LabelsController < ApplicationController
  before_filter do
    @list = current_user.lists.find(params[:list_id])
  end

  def create
    @label = @list.labels.build(params[:label].merge(:user_id => current_user.id))
    if @label.save
      render :partial => @label, :locals => {:list => @list}
    end
  end

  def destroy
    @label = @list.labels.find(params[:id])
    @label.done!
    render :nothing => true
  end
end
