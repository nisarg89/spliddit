// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require_directory .

function scrollToView(element){
    var offset = element.offset().top;
    var visible_area_start = $(window).scrollTop();
    var visible_area_end = visible_area_start + window.innerHeight;

    if(offset < visible_area_start || offset > visible_area_end){
        // Not in view so scroll to it
        $('html,body').animate({scrollTop: element.offset().top - 90}, 400);
        return false;
    }
   return true;
}

function addToMailingList() {
  var email = $('#ipt-mailing-list').val();
  if (email && email.length > 0) {
    $('#mailing-list').html('<br><p class="subscribe" style="text-align:center;width:100%;margin-top:10px;margin-bottom:3px;font-weight:bold">Thanks for subscribing!</p><br>');
    $.getScript('/mailing_list/add?email='+email);
  }
  return false;
}

// Google Analytics
(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
})(window,document,'script','//www.google-analytics.com/analytics.js','ga');

ga('create', 'UA-55662510-1', 'auto');
ga('send', 'pageview');