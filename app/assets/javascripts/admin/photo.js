var photo;
photo = function() {
  $('#photo-sort').sortable({
    axis: "y",
    update: function() {
      $.post($(this).data("photo-sort-url"), $(this).sortable("serialize"));
    }
  });
}

$(document).ready(photo);
$(document).on('page:load', photo);