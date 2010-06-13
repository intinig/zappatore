/*jslint passfail: true, browser: true, devel: true */
/*global $:false, jQuery:false, _:false, Configuration:false, DataPusher:false, EventHandler:false, LoginHandler */

$(function() {  
  DataPusher.init();
  Configuration.setDefaults();
  LoginHandler.checkLogin();
  EventHandler.init();    
});