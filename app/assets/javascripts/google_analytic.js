var ready;
ready = function() {
    $('#nav-drop').on('click', function(){
        if ($(this).attr('aria-expanded') == "false"){
            if(typeof ga != "undefined"){
                ga('send', 'event', 'navigation dropdown', 'open', '無');
            }
        }
    });
};
$(document).ready(ready);
$(document).on('page:load', ready);