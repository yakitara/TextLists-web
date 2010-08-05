module ApplicationHelper
  def extract_external_links(text)
    text.scan(ActionView::Helpers::TextHelper::AUTO_LINK_RE).map do
      link_to(image_tag("link.png"), $&, :target => "_blank")
    end.join.html_safe
  end

  def underscore_exclusively_whitespaces(text)
    (text || " ").sub(/^(\s+)$/){ $1.gsub(/\s/,"_") }
  end
end
