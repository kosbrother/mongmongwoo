module Admin::BannersHelper
  def bannerable_select_options
    Banner::BANNER_TYPES.map do |option|
      if option
        [t("bannerable.#{option}"), option]
      else
        [t("bannerable.NoLink"), option]
      end
    end
  end

  def bannerable_name_or_no_link(banner)
    banner.bannerable_type.present? ? t("bannerable.#{banner.bannerable_type}") : t("bannerable.NoLink")
  end

  def link_to_bannerable_path(banner)
    link_to "連結", banner.able_path, target: "_blank" if banner.bannerable_type.present?
  end
end