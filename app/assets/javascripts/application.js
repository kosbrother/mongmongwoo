// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require_tree .


var ready;
ready = function() {
    $('#cancelBanner').on('click', function(){
        $('.app-install-banner').hide();
    });
    //production details page: minus 1 order quantity
    $('.order-box .quantity-minus').on('click', function(){

        var quantity = parseInt($('#cart_item_item_quantity').val()),
            min = parseInt($('#cart_item_item_quantity').attr('min'));

        if (quantity > min)
            $('#cart_item_item_quantity').val(quantity - 1)
    });
    //production details page: plus 1 order quantity
    $('.order-box .quantity-plus').on('click', function(){

        var quantity = parseInt($('#cart_item_item_quantity').val()),
            max = parseInt($('#cart_item_item_quantity').attr('max'));
        if (quantity < max)
            $('#cart_item_item_quantity').val(quantity + 1)
    });
    //production details page: Show selected spec images
    $('.spec-photos > .icons > .icon').on('click', function(){
        var url = $(this).attr('src'),
            spec_id = $(this).data('id');
        $('.spec-photos > .icons > .icon').removeClass('active');
        $(this).addClass('active');
        $('.show').html("<img class='img-responsive' src=" + url + ">")
        $('.select option[value='+ spec_id +']').prop('selected', true);
    });

    //PRODUCTION DETAIL PAGE: show selected spec image from option
    $('#cart_item_item_spec_id').change(function(){
       console.log($(this).val());
        var id = '#spec-' + $(this).val(),
            url = $(id).attr('src');
        $('.spec-photos > .icons > .icon').removeClass('active')
        $(id).addClass('active');
        $('.show').html("<img class='img-responsive' src=" + url + ">")
    });

    //shopping cart page: minus 1 order quantity
    $('.cart-result .quantity-minus').on('click', function(){

        var cart_item_id = $(this).attr('data-id'),
            id = '#cart-item-' + cart_item_id + '-quantity',
            cart_id = $(this).attr('data-cart-id'),
            quantity = parseInt($(id).val()),
            min = parseInt($(id).attr('min'));

        if (quantity > min)
            $.ajax({
                url: '/carts/' + cart_id + '/cart_items/' + cart_item_id,
                data: { quantity: '-' },
                type:"PATCH",


                success: function(data){
                    $(id).val(quantity - 1);
                    $('#cart-item-' + cart_item_id +'-subtotal').text(data.subtotal);
                    $('#cart-sum').text(data.total);
                    $('#totalprice').text(data.total_with_shipping);
                },

                error:function(xhr, ajaxOptions, thrownError){
                    alert('錯誤發生，如問題持續發生，請聯繫客服人員');
                }
            });
        else
            $.ajax({
                url: '/carts/' + cart_id + '/cart_items/' + cart_item_id,
                data: { quantity: '-' },
                type:"PATCH",

                success: function(){
                    $('#cart-item-' + cart_item_id).remove();
                },

                error:function(xhr, ajaxOptions, thrownError){
                    alert('錯誤發生，如問題持續發生，請聯繫客服人員');
                }
            });
    });
    //shopping cart page: plus 1 order quantity
    $('.cart-result .quantity-plus').on('click', function(){

        var cart_item_id = $(this).attr('data-id'),
            id = '#cart-item-' + cart_item_id + '-quantity',
            cart_id = $(this).attr('data-cart-id'),
            quantity = parseInt($(id).val()),
            max = parseInt($(id).attr('max'));

        if (quantity < max)
            $.ajax({
                url: '/carts/' + cart_id + '/cart_items/' + cart_item_id,
                data: { quantity: '+' },
                type:"PATCH",

                success: function(data){
                    $(id).val(quantity + 1);
                    $('#cart-item-' + cart_item_id +'-subtotal').text(data.subtotal);
                    $('#cart-sum').text(data.total);
                    $('#totalprice').text(data.total_with_shipping);
                },

                error:function(xhr, ajaxOptions, thrownError){
                    alert('錯誤發生，如問題持續發生，請聯繫客服人員');
                }
            });
    });
    //shopping cart page: delete cart item
    $('.cart-item-delete').on('click', function(){
        var id = $(this).attr('data-id'),
            cart_id = $(this).attr('data-cart-id'),
            target = $('#cart-item-' + id);
        $.ajax({
            url: '/carts/' + cart_id + '/cart_items/' + id,
            type:"DELETE",

            success: function(){
                target.remove();
            },

            error:function(xhr, ajaxOptions, thrownError){
                alert('錯誤發生，如問題持續發生，請聯繫客服人員');
            }
        })
    })
};
$(document).ready(ready);
$(document).on('page:load', ready);

