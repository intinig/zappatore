/*global Pusher, Configuration, $ */

var DataPusher = {
  init: function() {
    this.server = new Pusher(Configuration.apiKey, Configuration.channelName);
    this.server.bind('room-create', function(room) {
      $("#log").prepend('<p class="create"><strong>' + room.players[0] + '</strong> just entered Room #' + room.rid + '</p>');
      $("#rooms").show();
      $("#rooms").append($.room(room));
    });
    this.server.bind('room-destroy', function(room) {
      $("#log").prepend('<p class="destroy"><strong>' + room.players[0] + '</strong> has just closed Room #' + room.rid + '</p>');
      $("#room" + room.rid).remove();
    });
  }
};

