var get_store;
get_store = function() {
  $('.ship-store-code').on('focus', function(){
    var self = $(this);
    self.autocomplete({
      delay: 500,
      source: function (request, response) {
        var store_code = self.val();
        $.ajax({
          url: "/admin/stores/get_store_options",
          type: "get",
          dataType: "json",
          data: {store_code: store_code},
          success: function(data){
            response(data.data);
          }
        });
      },
      minLength: 3
    });
  });
};

$(document).ready(get_store);
$(document).on('page:load', get_store);