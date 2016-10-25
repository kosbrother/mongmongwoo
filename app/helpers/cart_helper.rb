module CartHelper
  def render_cart_step(step)
    content_tag(:div, @step > step ? "✓" : step , class: @step < step ? 'undone' : 'done')
  end

  def render_step_bar(step)
    content_tag(:div, '',  class: @step > step ?  'bar -full' : 'bar')
  end

  def render_campaign_info(title, left_to_apply)
    content_tag(:div, class: "campaign-info") do
      concat "(#{title}, 還差"
      concat content_tag(:span, left_to_apply, class: "left-to-apply")
      concat ")"
    end
  end
end