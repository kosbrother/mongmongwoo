var cart;
cart = function() {
    //Ajax: select Taobao supplier and show items
    $('#select-taobao').change(function(){
        var taobao_id =  $(this).val(),
            item_list = $('#item-list'),
            spec_list = $('#spec-list');


        $.ajax({
            url: '/admin/taobao_suppliers/'+ taobao_id +'/items',
            type: 'GET',

            success: function(data){
                $('#item-list option').remove();
                data.items.forEach(function(item){
                    item_list.append($("<option/>", {
                        value: item.id,
                        text: item.id + '-' + item.name
                    }))
                });
                $('#spec-list option').remove();
                data.specs.forEach(function(spec){
                    spec_list.append($("<option/>", {
                        value: spec.id,
                        text: spec.id + '-' + spec.style
                    }))
                });
            },

            error: function(){
                alert('錯誤發生');
            }
        })
    });
    //Ajax: select Item and show specs
    $('#item-list').change(function(){
        var item_id =  $(this).val(),
            spec_list = $('#spec-list');

        $.ajax({
            url: '/admin/items/'+ item_id +'/specs',
            type: 'GET',

            success: function(data){
                $('#spec-list option').remove();

                data.forEach(function(spec){
                    spec_list.append($("<option/>", {
                        value: spec.id,
                        text: spec.id + '-' + spec.style
                    }))
                });
            },

            error: function(){
                alert('錯誤發生');
            }
        })
    });
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
    //search by item id: Select spec and update cart item spec_id
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
};

$(document).ready(cart);
$(document).on('page:load', cart);