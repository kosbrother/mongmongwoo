module Admin::NotificationsHelper
  def notification_photo(notification, size=nil)
    if notification.present?
      if size.present?
        image_url = notification.content_pic.send(size).url
      else        
        image_url = notification.content_pic.url
      end
    else
      case size
      when :thumb
        volume = "150x100"
      else
        volume = "600x400"
      end

      image_url = "http://placehold.it/#{volume}&text=No Pic"
    end

    image_tag(image_url, :class => "thumbnail")
  end

  def li_execute_status_link(options = {is_execute: Schedule.execute_statuses[:false]})
    is_execute = options[:is_execute]
    content_tag(:li, '', class: is_execute.to_s == params[:is_execute] ? 'active' : '') do
      link_to link_text(is_execute), admin_notifications_path(options)
    end
  end

  def link_text(execue_status)
    execue_status == Schedule.execute_statuses[:false] ? "排程推播" : "已推播"
  end
end