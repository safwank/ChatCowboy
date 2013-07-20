(function() {
  $(document).ready(function() {
    var down = 0;
    var no_last = 1;
    var last_x = 0,
        last_y = 0;
    var ctx;
    var socket;
    var color = '#000000';

    initConnection();
    initCanvas();

    function initConnection() {
      socket = new WebSocket(getSocketUrl(), 'chat-protocol')
      var alert = $('.alert');

      socket.onopen = function() {
        $(alert).text('Connection established');
        $(alert).removeClass('alert-error');
        $(alert).addClass('alert-success');
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
          if (i[0] == 'reset') {
            initCanvas();
          }

          f++;
        }
      }

      socket.onclose = function() {
        $(alert).text('Connection closed');
        $(alert).removeClass('alert-success');
        $(alert).addClass('alert-error');
      }
    }

    function initCanvas() {
      var canvas = document.createElement('canvas');
      canvas.height = 300;
      canvas.width = 480;
      ctx = canvas.getContext("2d");

      $('.drawing').empty();
      $('.drawing').append(canvas);

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
    }

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
      var sessionId = $('#sessionId').val();
      return protocol + url[0] + '/_ws?sessionId=' + sessionId;
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

    $('#color').change(function() {
      color = $(this).val();
    });

    $('#connect').click(function() {
      socket.close();
      initConnection();
      return false;
    });

    $('#reset').click(function() {
      initCanvas();
      socket.send('reset;');
    });
  });
})();