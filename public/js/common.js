jQuery(document).ready(function(){

	var pagetop = jQuery('#pagetop');
	pagetop.hide();	
	
	jQuery(window).scroll(function () {
	var winTop = jQuery(this).scrollTop();		
		if (winTop > 100) {
			pagetop.fadeIn(1000);
		}
		else {
			pagetop.fadeOut(150);
		}
	});

	pagetop.click(function () {
	jQuery('body,html').animate({ scrollTop: 0 }, 500);
	return false;
	});	
	
	var pageScroll = jQuery('.scroll a[href^=#]');	
	pageScroll.click(function () {
      var href= jQuery(this).attr("href");
      var target = $(href == '#' || href == "" ? 'html' : href);
      var position = target.offset().top;
      jQuery('body,html').animate({scrollTop:position}, 500);
      return false;
    });
				
	jQuery(".trigger").on("click", function() {
			jQuery(this).next().slideToggle();
	});

});