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

  def render_counter
    if current_cart.cart_items.count > 0
      content_tag(:div, current_cart.cart_items.count, class: 'counter' )
    else
      content_tag(:div, '', class: 'counter hidden' )
    end
  end

  def render_float_cart
    link_to checkout_path, onClick: analytic_event('float_cart', 'click', '無') do
      content_tag(:div, class: current_cart.cart_items.count > 0  ? 'float-box' : 'float-box hidden', id: 'cart-info') do
        image_tag('float_cart.png') +
        render_counter
      end
    end
  end

  def fb_picture
    "https://graph.facebook.com/#{current_user.uid}/picture?width=100&height=100"
  end

  def analytic_event(category, action, label)
    if Rails.env == "production"
      "ga('send', 'event', '#{category}', '#{action}', '#{label}');"
    end
  end

  def show_image(obj_image, image_size=nil)
    if obj_image.present?
      image_url = obj_image.url
    else
      image_url = "http://placehold.it/120x120&text=No Pic"
    end
    
    image_size ? image_tag(image_url, size: image_size) : image_tag(image_url)
  end
end