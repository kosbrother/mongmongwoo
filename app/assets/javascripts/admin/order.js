var get_store;
get_store = function() {
  $('.ship-store-code').on('focus', function(){
    var self = $(this);
    var order_id = $(this).data('order-id');
    var form = $('#edit_order_'+order_id);
    self.autocomplete({
      delay: 500,
      minLength: 3,
      source: function (request, response) {
        var store_code = self.val();
        $.ajax({
          url: "/admin/stores/get_store_options",
          type: "get",
          dataType: "json",
          data: {store_code: store_code},
          success: function(data){
            response(data.data);
            $('#submit-' + order_id).attr('disabled', false);
          },
          error: function(xhr, textStatus, errorThrown){
            var message = xhr.responseJSON.error.message
            $('#submit-' + order_id).attr('disabled', true);
            swal({ title: message, confirmButtonText: "請檢查門市店號" });
          }
        });
      }
    });
    form.submit(function(){
      var store_code = self.val().split(/：/)[0];
      self.val(store_code);
      $('#submit-' + order_id).attr('disabled', true);
    });
  });

  $('.btn-barcode').on('click', function() {
    var self = $(this);
    self.addClass('btn-info');
  });
};

$(document).ready(get_store);
$(document).on('page:load', get_store);