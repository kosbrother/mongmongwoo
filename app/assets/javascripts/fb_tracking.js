var fb_tracking;
fb_tracking = function() {
  $(".fb-track").on("click", function() {
    var track = $(this).data("fb-track");
    if (track !== "") {
      fbq('track', track);
    };
  });

  $(".-wishlist.uncheck").on("click", function() {
    var track = $(this).data("fb-track");
    if (track !== "") {
      fbq('track', track);
    };
  });
};
$(document).ready(fb_tracking);
$(document).on('page:load', fb_tracking);