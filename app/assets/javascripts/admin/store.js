var store;
store = function() {
  //Ajax select County show towns and roads
  $('#select-county').change(function() {
    var county_id = $(this).val();
    var town_list = $('#town-list');
    $.ajax({
      url: '/api/v3/counties/' + county_id + '/towns',
      type: 'GET',
      success: function(data) {
        $('#town-list option').remove();
        var towns = data["data"],
            first_town = towns[0];
        towns.forEach(function(town) {
          town_list.append($("<option/>", {
            value: town.id,
            text: town.name
          }))
        });
      },
      error: function() {
        alert('錯誤發生');
      }
    })
  });

  $('#road-list').on('focus', function() {
    var self = $(this);
    var town_id = $('#town-list').val();
    self.autocomplete({
      delay: 800,
      minLength: 2,
      source: function (request, response) {
        var road_name = self.val();
        $.ajax({
          url: '/admin/roads/get_road_options?town_id=' + town_id + '&road_name=' + road_name,
          type: "GET",
          success: function(data) {
            response(data.data);
          }
        });
      }
    });
  });
};

$(document).ready(store);
$(document).on('page:load', store);