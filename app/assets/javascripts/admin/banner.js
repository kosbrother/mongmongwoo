var banner;
banner = function() {
  $('#banner-type').on('change', function() {
    var type = $(this).val();
    $.ajax({
      url: '/admin/banners/render_select_form',
      type: 'GET',
      data: {banner_type: type}
    })
  });
}

$(document).ready(banner);
$(document).on('page:load', banner);