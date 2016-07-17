module EmailHelper
  def email_image_tag(image, **options)
    file_name = File.basename(image)
    attachments.inline[file_name] = File.read(Rails.root.join("app/assets/images/#{image}"))
    image_tag attachments[file_name].url, **options
  end

  def email_scss_image_tag(image)
    file_name = File.basename(image)
    attachments.inline[file_name] = File.read(Rails.root.join("app/assets/images/#{image}"))
    attachments[file_name].url
  end

  def email_spec_image_tag(spec, **options)
    file_name = File.basename(spec.style_pic.url)
    attachments.inline[file_name] = spec.style_pic.read
    image_tag attachments[file_name].url, **options
  end
end