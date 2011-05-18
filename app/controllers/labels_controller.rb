class LabelsController < ApplicationController
  before_filter do
    @list = current_user.lists.find(params[:list_id])
  end

  def create
    @label = @list.labels.build(params[:label].merge(:user_id => current_user.id))
    if @label.save
      json = {}
      json[:label] = render_to_string :partial => "label.html", :object => @label, :locals => {:list => @list}
      json[:item_labels] = @list.items.includes(:labels).all.inject({}) do |h, item|
        h.update(item.id => render_to_string(:partial => "items/label.html", :object => @label, :locals => {:list => @list, :item => item}))
      end
      render :json => json
    end
  end

  def update
    @label = @list.labels.find(params[:id])
    @label.attributes = params[:label]
    if @label.save
      json = {}
      json[:label_id] = @label.id
      json[:label] = render_to_string :partial => "label.html", :object => @label, :locals => {:list => @list}
      json[:item_labels] = @list.items.includes(:labels).all.inject({}) do |h, item|
        h.update(item.id => render_to_string(:partial => "items/label.html", :object => @label, :locals => {:list => @list, :item => item}))
      end
      render :json => json
    end
  end

  def destroy
    @label = @list.labels.find(params[:id])
    @label.done!
    render :nothing => true
  end
end
