var Configuration = {
  server: 'http://localhost:4567'
}

$(function() {
  $.checkLogin();
  
  // $.setupBoard();
  
  $("#submit-login").click(function() {
    $.login();
    return false
  })
  
  $("#enter-room").click(function() {
    $.createRoom();
    return false
  })
})

jQuery.login = function() {
  loginValue = $("#login").val();
  passwordValue = $("#password").val();
  $("#login").val("");
  $("#password").val("");
  if (loginValue && passwordValue) {
    $.post(
      Configuration.server + '/login', 
      { 
        login: loginValue, 
        password: passwordValue
      },
      function(data) {
        $.setCookie("auth", data.auth, 14);
        Configuration.auth = data.auth
        $.checkRoom(data.auth);
      }
    )      
  } else {
    alert("Must supply both login and password.")
  }
}

jQuery.checkLogin = function() {
  auth = $.getCookie("auth");
  if (auth) {
    Configuration.auth = auth;
    $.checkRoom(auth);
  }
}

jQuery.updateCredentials = function(loginValue) {
  $("#login-form").hide();
  $("#service").append("<p id=\"welcome\">Welcome, <strong>" + loginValue + "</strong> (<a href=\"#\" id=\"logout\">logout</a>)</p>");
  $("#logout").click(function() {
    auth = $.getCookie("auth");
    $.getJSON(Configuration.server + "/logout/" + auth, function(data) {
      $.resetLoginForm();
      $(".command").hide();
      $("#status").html("");
      Configuration.auth = null;
    })
  })
}

jQuery.resetLoginForm = function() {
  $("#welcome").remove();
  $("#login-form").show();
}

jQuery.setCookie = function(name, value, days) {
	if (days) {
		var date = new Date();
		date.setTime(date.getTime()+(days*24*60*60*1000));
		var expires = "; expires="+date.toGMTString();
	}
	else var expires = "";
	document.cookie = name+"="+value+expires+"; path=/";
}

jQuery.getCookie = function(name) {
	var nameEQ = name + "=";
	var ca = document.cookie.split(';');
	for(var i=0;i < ca.length;i++) {
		var c = ca[i];
		while (c.charAt(0)==' ') c = c.substring(1,c.length);
		if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
	}
	return null;  
}

jQuery.deleteCookie = function(name) {
	$.setCookie(name,"",-1);  
}

jQuery.createRoom = function() {
  $.post(Configuration.server + "/rooms/" + Configuration.auth,
  function(data) {
    $("#enter-room").hide();
    $("#new-game").show();
    $.getRoom(data.id)
  })

}

jQuery.getRoom = function(rid) {
  $.get(Configuration.server + "/rooms/" + rid + "/" + Configuration.auth,
  function(getData) {
    $("#status").html("Room ID: <strong>" + rid + "</strong> - Players: <strong>" + getData.players + "</strong> (<a href=\"#\" id=\"exit-room\">quit</a>)")
    $("#exit-room").click(function() {
      $.ajax({
        url: Configuration.server + '/rooms/' + rid + '/' + Configuration.auth,
        type: 'DELETE',
        success: function() {
          $("#status").html('');
          $("#enter-room").show();
        }
      })
    })
  })
}

jQuery.checkRoom = function(auth) {
  $.getJSON(Configuration.server + "/sessions/" + auth, function(data) {
    $.updateCredentials(data.login);        
    if (data.room) {
      $.getRoom(data.room);
    } else {
      $("#enter-room").show();
    }
  })
}