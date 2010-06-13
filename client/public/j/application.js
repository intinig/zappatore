/*jslint passfail: true, browser: true, devel: true */
/*global $:false, jQuery:false, _:false, Configuration:false, DataPusher:false, EventHandler:false */

$(function() {  
  DataPusher.init();
  Configuration.setDefaults();
    
  $.checkLogin();
  
  EventHandler.init();    
});

jQuery.signup = function() {
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
          Configuration.auth = data.auth;
          $.checkRoom(data.auth);
        }
      });
    } else {
      alert("Must supply both login and password.");
    }    
  }
};

jQuery.login = function() {
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
        Configuration.auth = data.auth;
        $.checkRoom(data.auth);
      }
    });
  } else {
    alert("Must supply both login and password.");
  }
};

jQuery.checkLogin = function() {
  var auth = $.getCookie("auth");
  if (auth && (auth !== undefined)) {
    Configuration.auth = auth;
    $.checkRoom(auth);
  }
};

jQuery.updateCredentials = function(loginValue) {
  $("#login-form").hide();
  $("#signup-form").hide();
  $("#service").append("<p id=\"welcome\">Welcome, <strong>" + loginValue + "</strong> (<a href=\"#\" id=\"logout\">logout</a>)</p>");
  $("#logout").click(function() {
    var auth = $.getCookie("auth");
    $.getJSON("/p?url=" + Configuration.server + "/logout/" + auth, function(data) {
      $.resetLoginForm();
      $(".command").hide();
      $("#status").html("");
      Configuration.auth = null;
    });
  });
};

jQuery.resetLoginForm = function() {
  $("#welcome").remove();
  $("#login-form").show();
};

jQuery.setCookie = function(name, value, days) {
  var expires;
  
	if (days) {
		var date = new Date();
		date.setTime(date.getTime()+(days*24*60*60*1000));
		expires = "; expires="+date.toGMTString();
	}
	else { expires = ""; }
	document.cookie = name+"="+value+expires+"; path=/";
};

jQuery.getCookie = function(name) {
	var nameEQ = name + "=";
	var ca = document.cookie.split(';');
	for(var i=0;i < ca.length;i++) {
		var c = ca[i];
		while (c.charAt(0)===' ') {
		  c = c.substring(1,c.length);
	  }
		if (c.indexOf(nameEQ) === 0) {
		  return c.substring(nameEQ.length,c.length);
	  }
	}
	return null;  
};

jQuery.deleteCookie = function(name) {
	$.setCookie(name,"",-1);  
};

jQuery.createRoom = function() {
  $.post("/p?url=" + Configuration.server + "/rooms/" + Configuration.auth,
  function(data) {
    $("#enter-room").hide();
    $("#new-game").show();
    $.getRoom(data.id);
  });

};

jQuery.getRoom = function(rid) {
  $.get("/p?url=" + Configuration.server + "/rooms/" + rid + "/" + Configuration.auth,
  function(getData) {
    $("#status").html("Room ID: <strong>" + rid + "</strong> - Players: <strong>" + getData.players + "</strong> (<a href=\"#\" id=\"exit-room\">quit</a>)");
    $("#exit-room").click(function() {
      $.ajax({
        url: "/p?url=" + Configuration.server + '/rooms/' + rid + '/' + Configuration.auth,
        type: 'DELETE',
        success: function() {
          $("#status").html('');
          $("#enter-room").show();
          $("#new-game").hide();
        }
      });
    });
  });
};

jQuery.checkRoom = function(auth) {
  $.ajax({
    url: "/p?url=" + Configuration.server + "/sessions/" + auth,
    success: function(data) {
      $.updateCredentials(data.login);        
      if (data.room) {
        $("#new-game").show();
        $.getRoom(data.room);
      } else {
        $("#enter-room").show();
        $.showRooms();
        $(".room").click(function() {
          alert('Clicked');
        });
      }
    },
    error: function(xhr) {
      if (404 == xhr.status) {
       $.showRooms(); 
      } else {
        alert(xhr.status + " " + xhr.responseText);
      }
    }
  });
};

jQuery.showRooms = function() {
  $.get(
    "/p?url=" + Configuration.server + "/rooms",
    function(data) {
      $("#rooms").html("");
      $("#rooms").show();
      _.each(data.rooms, function(room) {
        console.log(room);
        $("#rooms").append($.room(room));
      });
    }
  );
};