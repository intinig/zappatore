/*global Pusher, Configuration, $, InterfaceActions */

var DataPusher = {
  init: function() {
    DataPusher.server = new Pusher(Configuration.apiKey, Configuration.channelName);
    DataPusher.bindEvents();
  },
  bindEvents: function() {
    DataPusher.server.bind('room-create', InterfaceActions.roomCreated);
    DataPusher.server.bind('room-destroy', InterfaceActions.roomDestroyed);
  }
};

