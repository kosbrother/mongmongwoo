var campaign_rule;
campaign_rule = function(){
  $('#campaign_rule_discount_type').on('change', function(){
    var type =  $(this).val();
    if (type === 'percentage_off_next'){
      type = 'percentage_off'
    }
    var selector = '.discount-type[data-type=' + type + ']';
    $('.discount-type input').val("");
    $('.discount-type input').attr('required', false);
    $('.discount-type').addClass('hidden');
    $(selector).removeClass('hidden');
    $(selector + ' input').attr('required', true);
  });
};
$(document).ready(campaign_rule);
$(document).on('page:load', campaign_rule);