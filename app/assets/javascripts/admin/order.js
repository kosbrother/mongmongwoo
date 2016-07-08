var get_store;
get_store = function() {
  $('.ship-store-code').change(function(){
    var ship_store_code = $(this).val(),
        order_id = $(this).data('order-id');
    $.ajax({
      url: '/admin/stores/get_store?store_code=' + ship_store_code,
      type: 'GET',
      success: function(data){
        var store = data["data"];
        $('#store-name-' + order_id).val(store.name);
        $('#store-id-' + order_id).val(store.id);
      },
      error: function(data){
        var message = data.responseJSON.data
        alert(message);
      }
    })
  });
};

$(document).ready(get_store);
$(document).on('page:load', get_store);