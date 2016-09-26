var shopping_point;
shopping_point = function() {
  $('#shopping-point-type').on('change', function() {
    var type = $(this).val();
    var user_id = $(this).data('user-id');

    $.ajax({
      url: '/admin/users/' + user_id + '/shopping_points/render_select_form',
      type: 'GET',
      data: {shopping_point_type: type}
    })
  });
}

$(document).ready(shopping_point);
$(document).on('page:load', shopping_point);