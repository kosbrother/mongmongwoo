var cart;
cart = function() {
    //shopping cart page: minus 1 order quantity
    $('.cart-result .quantity-minus').on('click', function () {

        var cart_item_id = $(this).attr('data-id'),
            id = '#cart-item-' + cart_item_id + '-quantity',
            quantity = parseInt($(id).val()),
            min = parseInt($(id).attr('min'));

        if (quantity > min)
            $.ajax({
                url: '/cart_items/' + cart_item_id + '/update_quantity',
                data: {type: 'quantity-minus'},
                type: "PATCH",


                success: function (data) {
                    $(id).val(quantity - 1);
                    $('#cart-item-' + cart_item_id + '-subtotal').text(data.subtotal);
                    $('#ship-fee').text(data.ship_fee);
                    $('#cart-sum').text(data.total);
                    $('#totalprice').text(data.total_with_shipping);
                },

                error: function (xhr, ajaxOptions, thrownError) {
                    alert('錯誤發生，如問題持續發生，請聯繫客服人員');
                }
            });
        else
            $("#modal-" + cart_item_id).modal('show');
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

                success: function (data) {
                    $(id).val(quantity + 1);
                    $('#cart-item-' + cart_item_id + '-subtotal').text(data.subtotal);
                    $('#ship-fee').text(data.ship_fee);
                    $('#cart-sum').text(data.total);
                    $('#totalprice').text(data.total_with_shipping);
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
            counter = parseInt($('#nav-bar-collapse .cart > .counter').text());

        setTimeout(function(){
            $.ajax({
                url: '/cart_items/' + id,
                type: "DELETE",
                success: function (data) {
                    target.remove();
                    $('#nav-bar-collapse .cart > .counter').text(counter - 1);
                    $('#ship-fee').text(data.ship_fee);
                    $('#cart-sum').text(data.total);
                    $('#totalprice').text(data.total_with_shipping);
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
        var name = $('#ship_name').val(),
            email = $('#ship_email').val(),
            phone = $('#ship_phone').val();

        $.get( "/select_store", { name: name, email: email, phone: phone }, function(data){
            window.location = data['url']
        });
    });
};

$(document).ready(cart);
$(document).on('page:load', cart);