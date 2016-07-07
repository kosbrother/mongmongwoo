var store;
store = function() {
  //Ajax select County show towns and roads
  $('#select-county').change(function() {
    var county_id = $(this).val(),
        town_list = $('#town-list'),
        road_list = $('#road-list');
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
        $.ajax({
          url: '/api/v3/counties/' + county_id + '/towns/' + first_town.id + '/roads',
          type: 'GET',
          success: function(data) {
            $('#road-list option').remove();
            data["data"].forEach(function(road) {
              road_list.append($("<option/>", {
                value: road.id,
                text: road.name
              }))
            });
          }
        })
      },
      error: function() {
        alert('錯誤發生');
      }
    })
  });
  
  //Ajax select Town show roads
  $('#town-list').change(function() {
    var county_id = $('#select-county').val(),
        town_id = $(this).val(),
        road_list = $('#road-list');
    $.ajax({
      url: '/api/v3/counties/' + county_id + '/towns/' + town_id + '/roads',
      type: 'GET',
      success: function(data) {
        $('#road-list option').remove();
        data["data"].forEach(function(road) {
          road_list.append($("<option/>", {
            value: road.id,
            text: road.name
          }))
        });
      },
      error: function() {
        alert('錯誤發生');
      }
    })
  });
};

$(document).ready(store);
$(document).on('page:load', store);