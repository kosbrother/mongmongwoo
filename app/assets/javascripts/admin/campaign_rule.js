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
    if(type === 'shopping_point'){
      $('.check-box-group input').attr('checked', false);
      $('.check-box-group').hide();
      $('#campaign-rule-datetime').hide();
      $(selector + ' .shopping-point-campaign-title').val($('#campaign_rule_title').val());
      $(selector + ' .shopping-point-campaign-description').val($('#campaign_rule_description').val());
      $(selector + ' .un-required input').attr('required', false);
      $('#campaign_rule_campaign_for_order').prop('value', true);
      $(selector + ' .is_reusable input[type=hidden]').val("1");
    }else{
      $('.check-box-group').show();
      $('#campaign-rule-datetime').show();
    }
  });
  $('#campaign_rule_rule_type').on('change', function(){
    var type = $(this).val();
    if (type === 'exceed_amount'){
      $('.campaign-for-order').removeClass('hidden');
      $('.campaign-for-items').addClass('hidden');
      $('#campaign_rule_campaign_for_order').prop('value', true);
      $('.campaign-for-items input').prop('checked', false);
    }else if(type === 'exceed_quantity'){
      $('.campaign-for-items').removeClass('hidden');
      $('.campaign-for-order').addClass('hidden');
      $('#campaign_rule_campaign_for_order').prop('value', false);
    }
  });
};
$(document).ready(campaign_rule);
$(document).on('page:load', campaign_rule);