var bindFacebookEvents, initializeFacebookSDK, loadFacebookSDK, restoreFacebookRoot, saveFacebookRoot;

initializeFacebookSDK = function() {
  FB.init({
    appId: '1101896056521102',
    xfbml: true,
    version    : 'v2.8'
  });
};

loadFacebookSDK = function() {
  window.fbAsyncInit = initializeFacebookSDK;
  $.getScript("//connect.facebook.net/zh_TW/sdk.js");
};

saveFacebookRoot = function() {
  if ($('#fb-root').length) {
    this.fbRoot = $('#fb-root').detach();
  }
};

restoreFacebookRoot = function() {
  if (this.fbRoot != null) {
    if ($('#fb-root').length) {
      $('#fb-root').replaceWith(this.fbRoot);
    } else {
      $('body').append(this.fbRoot);
    }
  }
};

bindFacebookEvents = function() {
  $(document).on('page:fetch', saveFacebookRoot).on('page:change', restoreFacebookRoot).on('page:load', function() {
    typeof FB !== "undefined" && FB !== null ? FB.XFBML.parse() : void 0;
  });
  this.fbEventsBound = true;
};

$(function() {
  loadFacebookSDK();
  if (!window.fbEventsBound) {
    bindFacebookEvents();
  }
});