jQuery.actionSpace = function(action) {
  return '<div id="' + action["id"] +'" class="action">' + action["name"] + '</div>'  
}

jQuery.turnActionSpace = function(action) {
  h = '<h5>Turno ' + action["turn"] + '</h5>';
  if (action["revealed"]) {
    p = '<p>' + action["name"];
    klass = "action";    
  } else {
    p = '<p></p>'
    klass = "action hidden"
  }
  return '<div id="' + action["id"] + '" class="' + klass + '">' + h + p + '</div>';
}

jQuery.phaseLoop = function(data, phase, offset) {
  for (i in data["phases"][phase - 1]) {
    data["phases"][phase - 1][i].turn = (parseInt(i) + offset);
    $("#r" + phase).append($.turnActionSpace(data["phases"][phase - 1][i]));
  }
}

jQuery.setupBoard = function() {
  $.getJSON(Configuration.server + '/games/1/board', function(data) {
    for  (i in data.starting) {
      $("#starting").append($.actionSpace(data.starting[i]));
    }

    for (i in data["default"]) {
      $("#default").append($.actionSpace(data["default"][i]));
    }

    $.phaseLoop(data, 1, 1);
    $.phaseLoop(data, 2, 5);
    $.phaseLoop(data, 3, 8);
    $.phaseLoop(data, 4, 10);
    $.phaseLoop(data, 5, 12);
    $.phaseLoop(data, 6, 14);

    $.addHandlers();
  })  
}

jQuery.addHandlers = function() {
  $("#submitter").click(function() {
    alert('ciola');
    return false;
  })
}