var ec_tracking;
ec_tracking = function() {
  $('.add-to-cart-track').on('click', function() {
    var id = $(this).data('item-id');
    var name = $(this).data('item-name');
    var price = $(this).data('item-price');

    fbq('track', 'AddToCart', {
      content_name: name,
      content_ids: [id],
      content_type: 'product',
      value: price,
      currency: 'TWD'
    });

    ga('ec:addProduct', {
      'id': id,
      'name': name,
      'price': price
    });
    ga('ec:setAction', 'add');
    ga('send', 'event', 'add_to_cart', 'click', name);
  });

  $('#float-cart').on('click', function(){
    ga('send', 'event', 'float_cart', 'click', '無');
  });
};
$(document).ready(ec_tracking);
$(document).on('page:load', ec_tracking);