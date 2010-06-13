/*global $, LoginHandler, InterfaceActions, ServerInterface*/
var EventHandler = {
  init: function() {
    $("#submit-login").click(function() {
      LoginHandler.login();
      return false;
    });

    $("#submit-signup").click(function() {
      LoginHandler.signup();
      return false;
    });

    $("#enter-room").click(function() {
      ServerInterface.createRoom();
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
  },
  enableLogout: function() {
    $("#logout").click(function() {
      var auth = $.getCookie("auth");
      $.getJSON("/p?url=" + Configuration.server + "/logout/" + auth, function(data) {
        InterfaceActions.resetLoginForm();
        $(".command").hide();
        $("#status").html("");
        Session.auth = null;
      });
    });
  }  
};