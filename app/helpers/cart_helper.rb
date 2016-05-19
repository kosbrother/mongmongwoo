module CartHelper
  def render_cart_step(step)
    content_tag(:div, @step > step ? "✓" : step , class: @step < step ? 'undone' : 'done')
  end

  def render_step_bar(step)
    content_tag(:div, '',  class: @step > step ?  'bar -full' : 'bar')
  end
end