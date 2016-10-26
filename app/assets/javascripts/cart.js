var cart;
cart = function() {
    //shopping cart page: minus 1 order quantity
    $('.cart-result .quantity-minus').on('click', function () {

        var cart_item_id = $(this).attr('data-id'),
            id = '#cart-item-' + cart_item_id + '-quantity',
            quantity = parseInt($(id).val()),
            min = parseInt($(id).attr('min'));

        if (quantity > min) {
            $.ajax({
                url: '/cart_items/' + cart_item_id + '/update_quantity',
                data: {type: 'quantity-minus'},
                type: "PATCH",
                success: function () {
                  ga('send', 'event', 'checkout_step_1', "click", "quantity_minus");
                },
                error: function (xhr, ajaxOptions, thrownError) {
                    alert('錯誤發生，如問題持續發生，請聯繫客服人員');
                }
            });
        } else {
            $("#modal-" + cart_item_id).modal('show');
        }
    });

    //shopping cart page: plus 1 order quantity
    $('.cart-result .quantity-plus').on('click', function () {

        var cart_item_id = $(this).attr('data-id'),
            id = '#cart-item-' + cart_item_id + '-quantity',
            quantity = parseInt($(id).val()),
            max = parseInt($(id).attr('max'));

        if (quantity < max)

            $.ajax({
                url: '/cart_items/' + cart_item_id + '/update_quantity',
                data: {type: 'quantity-plus'},
                type: "PATCH",
                success: function () {
                    ga('send', 'event', 'checkout_step_1', "click", "quantity_plus");
                },
                error: function (xhr, ajaxOptions, thrownError) {
                    alert('錯誤發生，如問題持續發生，請聯繫客服人員');
                }
            });
    });

    //shopping cart page: delete cart item
    $('.cart-item-delete').on('click', function () {

        var id = $(this).attr('data-id'),
            target = $('#cart-item-' + id),
            counter = parseInt($('#nav-bar-collapse .cart > .counter').text()),
            item_id = $(this).data('item-id'),
            item_name = $(this).data('item-name'),
            item_price = $(this).data('item-price');

        setTimeout(function(){
            $.ajax({
                url: '/cart_items/' + id,
                type: "DELETE",
                success: function () {
                    target.remove();
                    $('#nav-bar-collapse .cart > .counter').text(counter - 1);
                    fbq('trackCustom', 'RemoveFromCart', {
                      content_name: item_name,
                      content_ids: [item_id],
                      content_type: 'product',
                      value: item_price,
                      currency: 'TWD'
                    });

                    ga('ec:addProduct', {
                      'id': item_id,
                      'name': item_name,
                      'price': item_price
                    });
                    ga('ec:setAction', 'remove');
                    ga('send', 'event', 'remove_from_cart', 'click', item_name);
                  },
                error: function (xhr, ajaxOptions, thrownError) {
                    alert('錯誤發生，如問題持續發生，請聯繫客服人員');
                }
            })
        }, 200);
    });


    //sopping cart page: change selected item spec
    $('.cart-result .spec-select').change(function () {
        var spec_id = $(this).val(),
            cart_item_id = $(this).data('cart-item');

        $.ajax({
            url: '/cart_items/' + cart_item_id + '/update_spec',
            data: { item_spec: spec_id },
            type: "PATCH",

            success: function (data) {
                $("#item-spec-pic-" + cart_item_id).attr("src", data['spec_style_pic']);
            },

            error: function (xhr, ajaxOptions, thrownError) {
                alert('錯誤發生，如問題持續發生，請聯繫客服人員');
            }
        })
    });
//    Select store
    $('.select-store').on('click', function() {
        var ship_name = $('#ship_name').val(),
            ship_email = $('#ship_email').val(),
            ship_phone = $('#ship_phone').val();

        $.get( "/select_store", { ship_name: ship_name, ship_email: ship_email, ship_phone: ship_phone }, function(data){
            window.location = data['url']
        });
    });
    //click to use shopping point
    $('#shopping-point-check-box').on("click", function(){
        $.ajax({
            url: '/toggle_shopping_point',
            type: "patch",
            error: function (xhr, ajaxOptions, thrownError) {
                alert('錯誤發生，如問題持續發生，請聯繫客服人員');
            }
        })
    });
    //select ship_type
    $('#select-ship-type').change(function(){
       $.ajax({
           url: '/update_ship_type',
           data: {ship_type: $(this).val()},
           type: "patch",
           error: function (xhr, ajaxOptions, thrownError) {
               alert('錯誤發生，如問題持續發生，請聯繫客服人員');
           }
       })
    });

    //select county
    $('#select-county').change(function(){
        var county_id = $(this).val();
        $.ajax({
            url: '/get_towns',
            data: {county_id: county_id},
            type: 'get',
            error: function (xhr, ajaxOptions, thrownError) {
                alert('錯誤發生，如問題持續發生，請聯繫客服人員');
            }
        })
    });

    //validate ship name format
    $('#submit-info').on('click', function () {
        var format = /^[一-\u9fa5]*$/;
        var name = $('#ship_name').val();
        if (format.test(name) === false) {
            $('#ship_name').val('');
            $('#errors-modal').modal('show');
        }
    });
};

$(document).ready(cart);
$(document).on('page:load', cart);