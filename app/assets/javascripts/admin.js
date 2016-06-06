// common script for all pages
//= require jquery
//= require jquery-ui/core
//= require jquery-ui/draggable
//= require jquery-ui/resizable
//= require jquery-ui/position
//= require jquery-ui/sortable
//= require jquery-ui/mouse
//= require jquery_ujs
//= require jquery-fileupload/basic
//= require bootstrap
//= require custom
//= require jquery.dataTables.min
//= require dataTables.bootstrap
//= require ckeditor/init
//= require pnotify.custom.min
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
  // $("#select-item").hide();
  $('#notification_category_id').on('change', function() {
    if ( this.value == '16') {
      $("#select-item").show();
    }
  });

  $('#notification_category_id').change(function() {
    $.ajax({
       url: "admin/notifications/new", // this will be routed
       type: 'GET',
       data: {
         send_id: $("#yourIdContainer").val()
       },
       async: true,
       dataType: "json",
       error: function(XMLHttpRequest, errorTextStatus, error){
                  alert("Failed: "+ errorTextStatus+" ;"+error);
              },
       success: function(data){
          // here we iterate the json result
          for(var i in data)
          {
            var id = data[i].id;
            var title = data[i].title;
            $("#subject_select").append(new Option(title, id));
          }        

       }
     });
  });

};
$(document).ready(ready);
$(document).on('page:load', ready);