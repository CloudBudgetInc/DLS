$(document).ready(function () {

  //$('.custom-select-tag').selectbox({
    //'speed':0
  //});

  // Stick mobile menu bar
  $('.mobile-menu-bar').waypoint('sticky', {
    direction: 'down right',
    stuckClass: 'stuck',
    wrapper: '<div class="mobile-menu-sticky-wrapper" />'
  });

  $('.main-navigation').waypoint('sticky', {
    direction: 'down right',
    stuckClass: 'stuck',
    wrapper: '<div class="mobile-nav-sticky-wrapper" />'
  });

  // Apply fitvids to the testimonial videos
  $('.testimonial-video').fitVids();

  // TABS
  $(".tabs-nav a").on('click', function(e) {
    e.preventDefault();
    var $container = $(this).parents('.tabs-container');
    var index = $(this).parent('li').index() + 1;

    if ($(this).parent('li').hasClass('is-active')) {
      $container.find('.tabs-nav li').removeClass('is-active');
      $container.find('.tabs-content-section').removeClass('is-active');
      return;
    }

    $container.find('.tabs-nav li').removeClass('is-active');
    $container.find('.tabs-content-section').removeClass('is-active');

    $(this).parent('li').addClass('is-active');
    $(this).parents('.tabs-container')
      .find('.tabs-content-section:nth-child('+index+')')
      .addClass('is-active');
  });

  $('.tabs-container').each(function() {
    var totalTabs = $(this).children('.tabs-nav').children().length;

    $(this).addClass('tabs-'+totalTabs);
  });

  $('.icon-search').on('click', function(e) {
    e.preventDefault();
    $('body').toggleClass('search-is-active');
  });

  $('.show-menu').on('click', function(e) {
    e.preventDefault();
    $('body').toggleClass('mobile-nav-is-active');
  });

  $('.sub-nav-toggle').on('click', function(e) {
    e.preventDefault();
    $(this).toggleClass('sub-nav-is-active');
  });

  $('.scroll-to-top').on('click', function(e) {
    e.preventDefault();
    $('body,html').animate({scrollTop: 0}, 300);
  });

  $('.carousel-with-thumbs .selector').flexslider({
    animation: "slide",
    controlNav: false,
    animationLoop: false,
    slideshow: false,
    itemWidth: 125,
    itemMargin: 24,
    asNavFor: '.carousel-with-thumbs .main-slides'
  });

  $('.carousel-with-thumbs .main-slides').flexslider({
    animation: "slide",
    controlNav: false,
    animationLoop: false,
    slideshow: false,
    sync: '.carousel-with-thumbs .selector'
  });

  $('.full-width-carousel').flexslider({
    controlNav: false,
    animation: "slide"
  });

  $('.team-member > a').on('click', function(e) {
    e.preventDefault();
    $('.team-member').removeClass('is-active');
    $('.team-member-list-overlay').addClass('is-active');
    $(this).parent('li').addClass('is-active');
  });

  $('.team-member-list-overlay, .close-button').on('click', function(e) {
    e.preventDefault();
    $('.team-member, .team-member-list-overlay').removeClass('is-active');
  });

  $('.our-team-filter-link').on('click', function(e) {
    e.preventDefault();

    $('.team-member, .team-member-list-overlay').removeClass('is-active');

    if($(this).hasClass('active'))
    {
      $('.team-member').removeClass('is-highlighted');
      $(this).removeClass('active');
    }
    else
    {
      var group = $(this).attr('data-filter');
      $('.team-member').removeClass('is-highlighted');
      $('.team-member[data-group="'+group+'"]').addClass('is-highlighted');
      $(this).addClass('active');
    }

  });

  $('.our-team-nav a').on('click', function(e) {
    e.preventDefault();
    var totalItems = $('.team-member-list > li').length;
    var $teamMember = $(this).parents('.team-member');
    var index = $teamMember.index() + 1;

    $(this).hasClass('our-team-next') ? index++ : index--;

    if (index >= totalItems) {
      index = 1;
    } else if (index <= 0) {
      index = totalItems;
    }

    $('.team-member').removeClass('is-active');

    $('.team-member:nth-child('+index+')').addClass('is-active');


  });

  $('.mobile-description-toggle').on('click', function(e) {
    e.preventDefault();
    $(this).parents('.team-member').find('.description').toggleClass('is-active');
    $(this).toggleClass('is-active');
  });

  $('.share').on('click', function(e) {
    e.preventDefault();
    $(this).parents('.share-wrap').find('.share-drop').toggleClass('is-active');
  });

  // $('.date-input').datepick({
  //   showOtherMonths: true,
  //   showAnim: '',
  //   alignment: 'bottom',
  //   dayNamesMin: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
  //   prevText: '<span class="icon icon-arrowleft"></span>',
  //   nextText: '<span class="icon icon-arrowright"></span>'
  // });

  //$('.date-input').datepicker();

  $('.mobile-show-search').on('click', function(e) {
    $('body').toggleClass("mobile-search-is-active");
  });

  $('.trigger-student-login').on('click', function(e) {
    e.preventDefault();
    $('body').toggleClass("student-login-modal-active");
  });

  $('.close-button, .login-overlay').on('click', function() {
    $('body').removeClass("student-login-modal-active");
  });

});
