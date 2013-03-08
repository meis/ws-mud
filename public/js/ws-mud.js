$(function () {
  var ws;

  var WSMud = {};
  _.extend(WSMud, Backbone.Events);
  
  WSMud.create_socket = function () {
    ws = new WebSocket(ws_url);
    
    ws.onopen = function () {  
      WSMud.trigger("connect");
    };
    
    ws.onclose = function () {
      WSMud.trigger("connect");
    };

    ws.onmessage = function (msg) {
      var res = JSON.parse(msg.data);      
      WSMud.trigger(res.type, res);
    };
  }

  $('#console-input').keydown(function (e) {
    if (e.keyCode == 13 && $('#console-input').val()) {
    	var cmd = JSON.stringify({"type": "cmd", "text": $('#console-input').val()});
      ws.send(cmd);
      WSMud.trigger("echo", {"text":'> ' + $('#console-input').val(),"type":"echo"});
      $('#console-input').val('');
    }
  });
  
  WSMud.create_socket();  

  // CONSOLE MODULE  
  var WSMud_console = {};
  _.extend(WSMud_console, Backbone.Events);

  WSMud_console.update = function (notification) {
    var color = (notification.color? "style='color:" + notification.color + "'": "");
    $('#console').append("<span " + color + "class='" + notification.type.replace(":","-") + "'>" + notification.text + '</span>');
    $('#console').scrollTop(9999999999999);
  }
  
  WSMud_console.connected = function (notification) {    
    WSMud_console.update({"text":"Connection opened","type":"message"});    
  }
  
  WSMud_console.disconnected = function (notification) {    
    WSMud_console.update({"text":"Connection closed","type":"message"});    
  }

  WSMud_console.listenTo(WSMud, { 
    "connect"     : WSMud_console.connected,
    "disconnect"  : WSMud_console.disconnected,
  
    "echo"        : WSMud_console.update,
    "message"     : WSMud_console.update,
    "room:glance" : WSMud_console.update,
    "room:look"   : WSMud_console.update,
    "room:players": WSMud_console.update,
    "error"       : WSMud_console.update
  });   

  $('#console-input').focus(); 
	
	// CONNECTION SWITCHER MODULE
	var WSMud_connection_switcher = {};
  _.extend(WSMud_connection_switcher, Backbone.Events);
  
  WSMud_connection_switcher.connected = function (notification) {   
    $('#connection-switcher span').html("Disconnect"); 
  }
  
  WSMud_connection_switcher.disconnected = function (notification) {    
    $('#connection-switcher span').html("Connect");   
  }
  
  WSMud_connection_switcher.listenTo(WSMud, { 
    "connect"     : WSMud_connection_switcher.connected,
    "disconnect"  : WSMud_connection_switcher.disconnected,
  });
  
  $('#connection-switcher').click(function (e) {
  	if (ws.readyState == 1) 
  		ws.close();
  	else
  		create_socket();    
  });
  
  



});
