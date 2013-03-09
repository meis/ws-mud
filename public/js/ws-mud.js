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
      WSMud.trigger("disconnect");
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
    "help"        : WSMud_console.update,
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
  
  WSMud_connection_switcher.switch_connection = function () {    
    if (ws.readyState == 1) 
  		ws.close();
  	else
  		WSMud.create_socket();   
  }
  
  WSMud_connection_switcher.listenTo(WSMud, { 
    "connect"     : WSMud_connection_switcher.connected,
    "disconnect"  : WSMud_connection_switcher.disconnected,
  });
  
  $('#connection-switcher').click(function (e) {
    WSMud_connection_switcher.switch_connection();
  });
  
  // USER LIST MODULE
	var WSMud_user_list = {};
	WSMud_user_list.users = [];
  _.extend(WSMud_user_list, Backbone.Events);
  
  WSMud_user_list.render = function (notification) {   
    $("#widget-userlist h3").html("WHO");
    $("#widget-userlist div").html("<ul></ul>");
    
    WSMud_user_list.users = _.uniq(WSMud_user_list.users);
    WSMud_user_list.users.sort();
    
    for (i = 0; i < WSMud_user_list.users.length; ++i) {
      $("#widget-userlist div ul").append("<li>" + WSMud_user_list.users[i] + "</li>");
    }
  }
  
  WSMud_user_list.add_user = function (notification) {   
    WSMud_user_list.users = _.union(WSMud_user_list.users, notification.value.split(" "));
    WSMud_user_list.render();
  }
  
  WSMud_user_list.rem_user = function (notification) {        
    WSMud_user_list.users = _.without(WSMud_user_list.users, notification.value);
    WSMud_user_list.render();
  }
  
  WSMud_user_list.rem_all = function (notification) {     
	  WSMud_user_list.users = [];
    WSMud_user_list.render();
  }
  
  WSMud_user_list.listenTo(WSMud, { 
    "who"         : WSMud_user_list.add_user,
    "login"       : WSMud_user_list.add_user,
    "logout"      : WSMud_user_list.rem_user,
    "connect"     : WSMud_user_list.render,
    "disconnect"  : WSMud_user_list.rem_all,
  });
  
});
