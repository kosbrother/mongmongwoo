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
//= require_tree ./staff

var ready;
ready = function() {
  // cancell disabled before submit
  $("form.cancell-disabled-item-form").submit(function() {
    $("input.disabled").removeAttr("disabled");
  });
  // sub category check box
  $('.parent-category').change(function() {
    var self = $(this);
    var category_id = self.val();
    if (self.prop("checked") === true) {
      $.ajax({
        url: "/staff/categories/" + category_id + "/subcategory",
        type: "GET",
        success: function(data) {
          categories = data["data"]
          for (var i in categories) {
            var id = categories[i].id;
            var title = categories[i].name;
            $("#sub-category-field").append('<label class="checkbox-inline parent-' + category_id + '"><input class="checkbox" type="checkbox" value="' + id + '" name="item[category_ids][]">' + title + '</label>');
          }
        },
        error: function(XMLHttpRequest, errorTextStatus, error){
          alert("Failed: "+ errorTextStatus+" ;"+error);
        }
      });
    } else {
      $(".parent-" + category_id).remove();
    }
  });
};
$(document).ready(ready);
$(document).on('page:load', ready);