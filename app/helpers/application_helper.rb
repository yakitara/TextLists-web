module ApplicationHelper
  def extract_external_links(text)
    text.gsub(ActionView::Helpers::TextHelper::AUTO_LINK_RE).map do |m|
      link_to(image_tag("link.png"), m, :target => "_blank", :title => m)
    end.join.html_safe
  end

  def underscore_exclusively_whitespaces(text)
    (text || " ").sub(/^(\s+)$/){ $1.gsub(/\s/,"_") }
  end
end
