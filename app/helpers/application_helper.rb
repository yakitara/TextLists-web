module ApplicationHelper
  def extract_external_links(text)
    text.scan(ActionView::Helpers::TextHelper::AUTO_LINK_RE).map do
      link_to(image_tag("link.png"), $&, :target => "_blank")
    end.join.html_safe
  end
end
