var get_store;
get_store = function() {
  $('.ship-store-code').change(function(){
    var ship_store_code = $('.ship-store-code').val();
    $.ajax({
      url: '/admin/stores/get_store?store_code=' + ship_store_code,
      type: 'GET',
      success: function(data){
        var store = data["data"];
        $('.ship-store-name').val(store.name);
        $('.ship-store-id').val(store.id);
      },
      error: function(){
        alert('門市資料有誤，請確認門市相關資料');
      }
    })
  });
};

$(document).ready(get_store);
$(document).on('page:load', get_store);