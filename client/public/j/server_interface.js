var ServerInterface = {
  createRoom: function() {
    $.post("/p?url=" + Configuration.server + "/rooms/" + Session.auth,
    function(data) {
      $("#enter-room").hide();
      $("#new-game").show();
      ServerInterface.getRoom(data.id);
    });
  },
  getRoom: function(rid) {
    $.get("/p?url=" + Configuration.server + "/rooms/" + rid + "/" + Session.auth,
    function(getData) {
      $("#status").html("Room ID: <strong>" + rid + "</strong> - Players: <strong>" + getData.players + "</strong> (<a href=\"#\" id=\"exit-room\">quit</a>)");
      $("#exit-room").click(function() {
        $.ajax({
          url: "/p?url=" + Configuration.server + '/rooms/' + rid + '/' + Session.auth,
          type: 'DELETE',
          success: function() {
            $("#status").html('');
            $("#enter-room").show();
            $("#new-game").hide();
          }
        });
      });
    });
  },
  checkRoom: function(auth) {
    $.ajax({
      url: "/p?url=" + Configuration.server + "/sessions/" + auth,
      success: function(data) {
        LoginHandler.updateCredentials(data.login);        
        if (data.room) {
          $("#new-game").show();
          ServerInterface.getRoom(data.room);
        } else {
          $("#enter-room").show();
          ServerInterface.showRooms();
          $(".room").click(function() {
            alert('Clicked');
          });
        }
      },
      error: function(xhr) {
        if (404 == xhr.status) {
         ServerInterface.showRooms(); 
        } else {
          alert(xhr.status + " " + xhr.responseText);
        }
      }
    });
  },
  showRooms: function() {
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
  }
};