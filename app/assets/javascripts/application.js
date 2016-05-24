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
//= require jquery-ui
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
        $('.show').html("<img class='img-responsive' src=" + url + ">");
        $('.spec-select option[value='+ spec_id +']').prop('selected', true);
    });

    //PRODUCTION DETAIL PAGE: show selected spec image from option
    $('#cart_item_item_spec_id').change(function(){
        var id = '#spec-' + $(this).val(),
            url = $(id).attr('src');
        $('.spec-photos > .icons > .icon').removeClass('active');
        $(id).addClass('active');
        $('.show').html("<img class='img-responsive' src=" + url + ">")
    });

    //Hover on navbar's user, will show dropdown menu
    $('#user-nav').mouseenter(function(){
        $('#user').addClass('open');
    });
    $('#user-nav').mouseleave(function(){
        $('#user').removeClass('open');
    });

    //toggle for add to my favorite
    $('#add-favorite').on('click', function(){
            var id = $(this).data('id');
        if ($(this).hasClass('checked')){
            $.ajax({
                url: "/favorite_items/" + id + "/favorite",
                data: { type: 'un-favorite' },
                method: "PUT",

                success: function(){
                    $('#add-favorite').addClass('uncheck').removeClass('checked');
                },
                error: function (xhr, ajaxOptions, thrownError) {
                    alert('錯誤發生，如問題持續發生，請聯繫客服人員');
                }
            });
        }
        else if ($(this).hasClass('uncheck')){
            $.ajax({
                url: "/favorite_items/" + id + "/favorite",
                data: { type: 'favorite' },
                method: "PUT",

                success: function(error) {
                    if (!error){
                    $('#add-favorite').addClass('checked').removeClass('uncheck')
                    }
                },
                error: function (xhr, ajaxOptions, thrownError) {
                    alert('錯誤發生，如問題持續發生，請聯繫客服人員');
                }
            })
        }
    });
    //rmove from favorite list
    $('.remove-fav').on('click', function(){
        var id = $(this).data('id');

        $.ajax({
            url: "/favorite_items/" + id + "/favorite",
            data: { type: 'un-favorite' },
            method: "PUT",

            success: function() {
               $('#row-item-' + id).remove();
            },
            error: function (xhr, ajaxOptions, thrownError) {
                alert('錯誤發生，如問題持續發生，請聯繫客服人員');
            }
        })
    })
};
$(document).ready(ready);
$(document).on('page:load', ready);

