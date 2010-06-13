/*global $*/
var EventHandler = {
  init: function() {
    $("#submit-login").click(function() {
      $.login();
      return false;
    });

    $("#submit-signup").click(function() {
      $.signup();
      return false;
    });

    $("#enter-room").click(function() {
      $.createRoom();
      return false;
    });

    $("#signup").click(function() {
      $("#signup-form").show();
      $("#login-form").hide();
      return false;
    });

    $("#signup-cancel").click(function() {
      $("#signup-form").hide();
      $("#login-form").show();
      return false;
    }); 
  }  
};