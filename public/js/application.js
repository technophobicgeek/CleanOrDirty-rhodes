$(document).ready(function(){
  var buttons = $('regularButton');
  buttons.bind('click',function(){
    buttons.removeClass('active');
    $(this).addClass('active');
  });
});
    