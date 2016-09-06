var drop_down;
drop_down = function() {
    $('.dropdown.keep-open').on({
        "shown.bs.dropdown": function() { this.closable = false; },
        "click":             function() { this.closable = true; },
        "hide.bs.dropdown":  function() { return this.closable; }
    });
    $('#nav-bar-collapse .dropdown > .list.diamond.dropdown-toggle').on('click', function(){
        $(this).parent().toggleClass('open');
    });
};

$(document).ready(drop_down);
$(document).on('page:load', drop_down);
