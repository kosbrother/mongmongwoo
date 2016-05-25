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
};
$(document).ready(ready);
$(document).on('page:load', ready);