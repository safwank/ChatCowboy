$(document).ready(function() {
  function getSocketUrl() {
    var protocol;
    var url = document.URL;

    if (url.substring(0, 5) == "https") {
      protocol = "wss://";
      url = url.substr(8);
    } else {
      protocol = "ws://";
      if (url.substring(0, 4) == "http")
        url = url.substr(7);
    }

    url = url.split('/');
    var sessionId = document.getElementById("session_id").value;
    return protocol + url[0] + "/_ws?sessionId=" + sessionId;
  }

  var down = 0;
  var no_last = 1;
  var last_x = 0,
      last_y = 0;
  var ctx;
  var socket = new WebSocket(getSocketUrl(), "chat-protocol");
  var color = "#000000";

  try {
    socket.onopen = function() {
      document.getElementById("wslm_statustd").style.backgroundColor = "#40ff40";
      document.getElementById("wslm_status").textContent = " websocket connection opened ";
    }

    socket.onmessage = function(msg) {
      j = msg.data.split(';');
      f = 0;
      while (f < j.length - 1) {
        i = j[f].split(' ');
        if (i[0] == 'd') {
          ctx.strokeStyle = i[1];
          ctx.beginPath();
          ctx.moveTo(+(i[2]), +(i[3]));
          ctx.lineTo(+(i[4]), +(i[5]));
          ctx.stroke();
        }
        if (i[0] == 'c') {
          ctx.strokeStyle = i[1];
          ctx.beginPath();
          ctx.arc(+(i[2]), +(i[3]), +(i[4]), 0, Math.PI * 2, true);
          ctx.stroke();
        }

        f++;
      }
    }

    socket.onclose = function() {
      document.getElementById("wslm_statustd").style.backgroundColor = "#ff4040";
      document.getElementById("wslm_status").textContent = " websocket connection CLOSED ";
    }
  } catch (exception) {
    alert('<p>Error' + exception);
  }

  var canvas = document.createElement('canvas');
  canvas.height = 300;
  canvas.width = 480;
  ctx = canvas.getContext("2d");

  document.getElementById('wslm_drawing').appendChild(canvas);

  canvas.addEventListener('mousemove', onMouseMove, false);
  canvas.addEventListener('mousedown', onMouseDown, false);
  canvas.addEventListener('mouseup', onMouseUp, false);

  offsetX = offsetY = 0;
  element = canvas;

  if (element.offsetParent) {
    do {
      offsetX += element.offsetLeft;
      offsetY += element.offsetTop;
    } while ((element = element.offsetParent));
  }

  function updateColor() {
    color = document.getElementById("color").value;
  }

  function onMouseDown(ev) {
    down = 1;
  }

  function onMouseUp(ev) {
    down = 0;
    no_last = 1;
  }

  function onMouseMove(ev) {
    var x, y;

    if (ev.offsetX) {
      x = ev.offsetX;
      y = ev.offsetY;
    } else {
      x = ev.layerX - offsetX;
      y = ev.layerY - offsetY;
    }

    if (!down)
      return;
    if (no_last) {
      no_last = 0;
      last_x = x;
      last_y = y;
      return;
    }
    socket.send("d " + color + " " + last_x + " " + last_y + " " + x + ' ' + y + ';');

    last_x = x;
    last_y = y;
  }
});