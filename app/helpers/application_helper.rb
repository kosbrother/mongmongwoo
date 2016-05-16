module ApplicationHelper
  def notice_message
    alert_types = { :notice => :success, :alert => :danger }

    close_button_options = { class: "close", "data-dismiss" => "alert", "aria-hidden" => true }
    close_button = content_tag(:button, "x", close_button_options)

    alerts = flash.map do |type, message|
      alert_content = close_button + message
      alert_type = alert_types[type.to_sym] || type
      alert_class = "alert-message alert alert-#{alert_type} alert-dismissable"
      content_tag(:div, alert_content, class: alert_class)
    end

    alerts.join("\n").html_safe
  end

  def category_header_icon(id)
    image_tag("icons/category_header/#{id}.png")
  end

  def mobile?
    request.user_agent =~ /Android/i
  end

  def pagination_links(collection, options = {})
    options[:renderer] ||= BootstrapPaginationHelper::LinkRenderer
    options[:class] ||= 'pagination pagination-centered'
    options[:inner_window] ||= 2
    options[:outer_window] ||= 1
    options[:previous_label] = '上一頁'
    options[:next_label] = '下一頁'
    will_paginate(collection, options)
  end

  def price_with_unit(price)
    "NT." + price.to_s
  end

  def render_cart_step(step)
    content_tag(:div, @step > step ? "✓" : step , class: @step < step ? 'undone' : 'done')
  end

  def render_step_bar(step)
    content_tag(:div, '',  class: @step > step ?  'bar -full' : 'bar')
  end

  def render_login_or_logout
    if current_user.nil?
      content_tag(:a, content_tag(:div, '登入/註冊', class: 'list user'), href: "/auth/facebook")
    else
      content_tag(:a, content_tag(:div, "#{current_user.user_name} / 登出", class: 'list user'), href: "/signout")
    end

  end

end
