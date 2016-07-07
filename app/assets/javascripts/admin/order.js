$('#ship_store_code').change(function(){
  var ship_store_code = $('#ship_store_code').val();
  $.ajax({
    url: '/admin/stores/get_store?store_code=' + ship_store_code,
    type: 'GET',
    success: function(data){
      var store = data["data"];
      $('#ship_store_name').val(store.name);
      $('#ship_store_id').val(store.id);
    },
    error: function(){
      alert('門市資料有誤，請確認門市相關資料');
    }
  })
});