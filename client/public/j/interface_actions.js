var InterfaceActions = {
  resetLoginForm: function() {
    $("#welcome").remove();
    $("#login-form").show();
  },
  roomCreated: function(room) {
    $("#log").prepend('<p class="create"><strong>' + room.players[0] + '</strong> just entered Room #' + room.rid + '</p>');
    $("#rooms").show();
    $("#rooms").append($.room(room));
  },
  roomDestroyed: function(room) {
    $("#log").prepend('<p class="destroy"><strong>' + room.players[0] + '</strong> has just closed Room #' + room.rid + '</p>');
    $("#room" + room.rid).remove();
  }
};