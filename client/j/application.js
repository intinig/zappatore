$(function() {
  $.checkLogin();
  
  // $.setupBoard();
  
  $("#submit-login").click(function() {
    loginValue = $("#login").val();
    passwordValue = $("#password").val();
    $("#login").val("");
    $("#password").val("");
    if (loginValue && passwordValue) {
      $.post(
        'http://localhost:4567/login', 
        { 
          login: loginValue, 
          password: passwordValue
        },
        function(data) {
          $.setCookie("auth", data.auth, 14);
          $.updateCredentials(loginValue);
        }
      )      
    } else {
      alert("Must supply both login and password.")
    }
    return false
  })
  
  $("#new-game").click(function() {
    $.post('http://localhost:4567/games', function(data) {
      alert(data)
    });
    return false
  })
})

jQuery.checkLogin = function() {
  auth = $.getCookie("auth");
  if (auth) {
    $.getJSON("http://localhost:4567/sessions/" + auth, function(data) {
      $.updateCredentials(data.login);        
      $("#new-game").show()
    })
  }
}

jQuery.updateCredentials = function(loginValue) {
  $("#login-form").hide();
  $("#service").append("<p id=\"welcome\">Welcome, <strong>" + loginValue + "</strong> (<a href=\"#\" id=\"logout\">logout</a>)</p>");
  $("#logout").click(function() {
    auth = $.getCookie("auth");
    $.getJSON("http://localhost:4567/logout/" + auth, function(data) {
      $.resetLoginForm()
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
