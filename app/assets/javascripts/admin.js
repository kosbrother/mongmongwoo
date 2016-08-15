// common script for all pages
//= require jquery
//= require jquery-ui/core
//= require jquery-ui/draggable
//= require jquery-ui/resizable
//= require jquery-ui/position
//= require jquery-ui/sortable
//= require jquery-ui/mouse
//= require jquery-ui/autocomplete
//= require jquery_ujs
//= require jquery-fileupload/basic
//= require bootstrap
//= require custom
//= require jquery.dataTables.min
//= require dataTables.bootstrap
//= require ckeditor/init
//= require pnotify.custom.min
//= require jquery.datetimepicker.full.min
//= require_tree ./admin

//Ajax
var ready;
ready = function() {
  $('.edit_order').submit(function(){
    var id = $(this).data('target');
    $(id).modal('hide');
  })

  // cancell disabled before submit
  $("form.cancell-disabled-item-form").submit(function() {
    $("input.disabled").removeAttr("disabled");
  });

  // select item for notification
  $('#notification_category_id').change(function() {
    $.ajax({
      url: "/admin/notifications/get_items",
      type: 'GET',
      data: {
        category_id: $("#notification_category_id").val()
      },
      success: function(data){
        $("#notification_item_id").empty();

        for (var i in data) {
          var id = data[i].id;
          var title = id + '：' + data[i].name;
          $("#notification_item_id").append(new Option(title, id));
        }
      },
      error: function(XMLHttpRequest, errorTextStatus, error){
        alert("Failed: "+ errorTextStatus+" ;"+error);
      }
    });
  });

  // custom popover to display item spec image
  $('.preview').popover({
    'trigger':'hover',
    'html':true,
    'content':function(){
      return "<img src='"+$(this).data('imageUrl')+"' width='120' height='90'>";
    }
  });
  // datetimepicker selector
  $('.datetimepicker').datetimepicker();
};

$(document).ready(ready);
$(document).on('page:load', ready);