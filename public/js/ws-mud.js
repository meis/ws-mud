$(function () {
  $('#console-input').focus();

  var log = function (notification) {  
  	var color = (notification.color? "style='color:" + notification.color + "'": "");
    $('#console').append("<span " + color + "class='" + notification.type.replace(":","-") + "'>" + notification.text + '</span>');
    $('#console').scrollTop(300);
  };
  
	var ws;
	
	function create_socket() {
    ws = new WebSocket('ws://localhost:3000/mud/<%= $player_name %>');
    
    ws.onopen = function () {
      log({"text":"Connection opened","type":"message"});      
      $('#connection-switcher span').html("Disconnect");
    };
    
    ws.onclose = function () {
      log({"text":"Connection closed","type":"message"});
      $('#connection-switcher span').html("Connect");
    };

    ws.onmessage = function (msg) {
      var res = JSON.parse(msg.data);
      log(res); 
    };
  }

  $('#console-input').keydown(function (e) {
    if (e.keyCode == 13 && $('#console-input').val()) {
    	var cmd = JSON.stringify({"type": "cmd", "text": $('#console-input').val()});
      ws.send(cmd);
      log({"text":'> ' + $('#console-input').val(),"type":"echo"});
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
