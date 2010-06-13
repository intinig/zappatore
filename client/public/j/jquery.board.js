/*global jQuery:false, $:false, Configuration:false, _:false */

jQuery.actionSpace = function(action) {
  return '<div id="' + action.id +'" class="action">' + action.name + '</div>';
};

jQuery.room = function(room) {
  var roomString = '<div id="room' + room.rid + '" class="room">Room ' + room.rid +' (' + room.players.length + '/5)<ul>';
  _.each(room.players, function(player) {
    roomString += '<li>' + player + '</li>';
  });
  return roomString + "</ul></div>";
};

jQuery.turnActionSpace = function(action) {
  var p, klass;
  var h = '<h5>Turno ' + action.turn + '</h5>';
  if (action.revealed) {
    p = '<p>' + action.name;
    klass = "action";    
  } else {
    p = '<p></p>';
    klass = "action hidden";
  }
  return '<div id="' + action.id + '" class="' + klass + '">' + h + p + '</div>';
};

jQuery.phaseLoop = function(data, phase, offset) {
  var i;
  
  for (i in data.phases[phase - 1]) {
    if (data.phases[phase - 1].hasOwnProperty(i)) {
      data.phases[phase - 1][i].turn = (parseInt(i, 10) + offset);
      $("#r" + phase).append($.turnActionSpace(data.phases[phase - 1][i]));
    }
  }
};

jQuery.setupBoard = function() {  
  $.getJSON("/p?url=" + Configuration.server + '/games/1/board', function(data) {
    var j;
    
    for (j in data.starting) {
      if (data.starting.hasOwnProperty(j)) {
        $("#starting").append($.actionSpace(data.starting[j]));        
      }
    }

    for (j in data["default"]) {
      if (data["default"].hasOwnProperty(j)) {
        $("#default").append($.actionSpace(data["default"][j]));
      }
    }

    $.phaseLoop(data, 1, 1);
    $.phaseLoop(data, 2, 5);
    $.phaseLoop(data, 3, 8);
    $.phaseLoop(data, 4, 10);
    $.phaseLoop(data, 5, 12);
    $.phaseLoop(data, 6, 14);

    $.addHandlers();
  });
};

jQuery.addHandlers = function() {
  $("#submitter").click(function() {
    alert('ciola');
    return false;
  });
};