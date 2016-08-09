var cart;
cart = function() {
    //Select spec and update cart item spec_id
    $('.update-spec-id').change(function(){
        var cart_item_id =  $(this).data('cart-item'),
            spec_item_id = $(this).val(),
            taobao_supplier_id = $(this).data('supplier-id');

        $.ajax({
            url: '/admin/admin_cart_items/' + cart_item_id + '/update_spec',
            data: {spec_item_id: spec_item_id, taobao_supplier_id: taobao_supplier_id},
            type: 'PATCH',

            error: function(){
                alert('錯誤發生');
            }
        })
    });
    //search by item id: Select spec and update cart spec image
    $('#result-spec-id').change(function(){
        var item_id = $(this).data('item-id'),
            spec_item_id = $(this).val();

        $.ajax({
            url: '/admin/items/'+ item_id +'/item_specs/'+ spec_item_id +'/style_pic',
            type: 'GET',

            success: function(data){
                   $('#result-spec-pic > img').attr({'src': data['style_pic'] })
            },

            error: function(){
                alert('錯誤發生');
            }
        })
    });
    //Empty cart item can not submit
    $('.search-add-item').submit(function(){
        var item_id = $('#result-hidden-item-id').val();
        var spec_id = $('#result-spec-id').val();
        if (item_id === "" || spec_id === null) {
            swal({
                title: "請先選擇商品",
                timer: 800,
                showConfirmButton: false
            });
            return false;
        };
    });
    $('.cart-spec-pic').popover({
        'trigger':'hover',
        'html':true,
        'content':function(){
            return "<img src='"+$(this).attr('src')+"' width='120' height='120'>";
        }
    });
};

$(document).ready(cart);
$(document).on('page:load', cart);