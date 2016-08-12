// jquery file upload
var item_spec;
item_spec = function() {
  $(function() {
    $("#staff-new-item-spec").fileupload({
      dataType: "script"
    });
  });
};

$(document).ready(item_spec);
$(document).on('page:load', item_spec);