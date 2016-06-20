var cart;
cart = function() {
    //Ajax: select Taobao supplier and show items
    $('#select-taobao').change(function(){
        var taobao_id =  $(this).val(),
            item_list = $('#item-list');

        $.ajax({
            url: '/admin/taobao_suppliers/'+ taobao_id +'/items',
            type: 'GET',

            success: function(data){
                $('#item-list option').remove();
                data.forEach(function(item){
                    item_list.append($("<option/>", {
                        value: item.id,
                        text: item.name
                    }))
                });
            },

            error: function(){

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
                        text: spec.style
                    }))
                });
            },

            error: function(){

            }
        })
    })
};

$(document).ready(cart);
$(document).on('page:load', cart);