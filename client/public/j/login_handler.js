/*global $, Configuration */

var Session = {
  auth: null
};

var LoginHandler = {
  checkLogin: function() {
    var auth = $.getCookie("auth");
    if (auth && (auth !== undefined)) {
      Configuration.auth = auth;
      ServerInterface.checkRoom(auth);
    }
  },
  signup: function() {
    var loginValue = $("#signup-login").val();
    var passwordValue = $("#signup-password").val();
    var passwordConfirmationValue = $("#signup-confirm-password").val();

    if (passwordValue != passwordConfirmationValue) {
      alert("Passwords do not match.");
    } else {
      if (loginValue && passwordValue) {
        $("#signup-login").val("");
        $("#signup-password").val("");
        $("#signup-confirm-password").val("");

        $.ajax({
          url: "/p?url=" + Configuration.server + '/signup',
          type: "POST",
          data: {
            login: loginValue, 
            password: passwordValue,
            confirm: passwordConfirmationValue        
          },
          success: function(data) {
            $.setCookie("auth", data.auth, 14);
            Session.auth = data.auth;
            ServerInterface.checkRoom(data.auth);
          }
        });
      } else {
        alert("Must supply both login and password.");
      }    
    }
  
  },
  login: function() {
    var loginValue = $("#login").val();
    var passwordValue = $("#password").val();
    $("#login").val("");
    $("#password").val("");
    if (loginValue && passwordValue) {
      $.ajax({
        url: "/p?url=" + Configuration.server + '/login',
        type: "POST",
        data: {
          login: loginValue, 
          password: passwordValue        
        },
        success: function(data) {
          $.setCookie("auth", data.auth, 14);
          Session.auth = data.auth;
          ServerInterface.checkRoom(data.auth);
        }
      });
    } else {
      alert("Must supply both login and password.");
    }
  },
  updateCredentials: function(loginValue) {
    $("#login-form").hide();
    $("#signup-form").hide();
    $("#service").append("<p id=\"welcome\">Welcome, <strong>" + loginValue + "</strong> (<a href=\"#\" id=\"logout\">logout</a>)</p>");
    EventHandler.enableLogout();
  }
};