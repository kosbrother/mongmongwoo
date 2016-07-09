var get_store,
    availableTags = [
      "131571",
      "831598",
      "962704",
      "965356",
      "954035",
      "138228",
      "954035",
      "165415"
    ];
get_store = function() {
  $('.btn').click(function(){
    var order_id = $(this).data('order-id'),
        ship_store_code = $(this).next().find('#store-code-'+order_id);
    ship_store_code.change(function(){
      var store_code = $(this).val(),
          order_id = $(this).data('order-id');
      $('#submit-' + order_id).attr('disabled', true);
      $(this).autocomplete({
        source: availableTags,
        appendTo: "#edit_order_"+order_id,
        change: function( event, ui ) {"option", "appendTo", "#edit_order_"+order_id}
      });
      $.ajax({
        url: '/admin/stores/get_store?store_code=' + store_code,
        type: 'GET',
        success: function(data){
          var store = data["data"];
          $('#store-name-' + order_id).val(store.name);
          $('#store-id-' + order_id).val(store.id);
          $('#submit-' + order_id).attr('disabled', false);
        },
        error: function(xhr, textStatus, errorThrown){
          var message = xhr.responseJSON.error.message
          alert(message);
        }
      })
    });
  });
};

$(document).ready(get_store);
$(document).on('page:load', get_store);