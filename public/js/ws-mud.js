$(function () {
  $('#console-input').focus();

  var log = function (text, type) {
    $('#console').append("<span class='" + type.replace(":","-") + "'>" + text + '</span>');
    $('#console').scrollTop(300);
  };
  
	var ws;
	
	function create_socket() {
    ws = new WebSocket('ws://localhost:3000/mud/<%= $player_name %>');
    
    ws.onopen = function () {
      log('Connection opened', 'message');
      $('#connection-switcher span').html("Disconnect");
    };
    
    ws.onclose = function () {
      log('Connection closed', 'message');
      $('#connection-switcher span').html("Connect");
    };

    ws.onmessage = function (msg) {
      var res = JSON.parse(msg.data);
      log(res.text, res.type); 
    };
  }

  $('#console-input').keydown(function (e) {
    if (e.keyCode == 13 && $('#console-input').val()) {
    	var cmd = JSON.stringify({"type": "cmd", "text": $('#console-input').val()});
      ws.send(cmd);
      log('> ' + $('#console-input').val(), 'echo');
      $('#console-input').val('');
    }
  });
  
  $('#connection-switcher').click(function (e) {
  	if (ws.readyState == 1) 
  		ws.close();
  	else
  		create_socket();    
  });
  
  create_socket();
});
