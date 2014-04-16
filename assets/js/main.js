// Generated by CoffeeScript 1.6.2
var PaintBoard, PaintObject;

window.requestAnimFrame = (function() {
  return window.requestAnimationFrame || window.webkitRequestAnimationFrame || window.mozRequestAnimationFrame || function(callback) {
    return window.setTimeout(callback, 1000 / 60);
  };
})();

PaintObject = function(x, y, color) {
  var self;

  self = this;
  self.x = x;
  self.y = y;
  self.color = color;
  self.size = 10;
};

PaintBoard = function() {
  var canvas, paint, self;

  self = this;
  canvas = null;
  self.ctx = null;
  self.currentColor = 'black';
  self.paintObjects = [];
  self.mouseDown = false;
  self.lastX = null;
  self.lastY = null;
  self.socket = null;
  self.connectionId = null;
  self.construct = function() {
    self.setCanvas();
    self.setEventHandlers();
    self.setFrameAnimation();
    self.socket = new SockJS('/echo');
    /*
    		self.socket.onopen = (e) ->
    			self.connectionId = e
    			console.log e
    			return
    */

    self.socket.onmessage = function(e) {
      var data, obj, _i, _len, _ref;

      data = JSON.parse(e.data);
      if (data.hasOwnProperty('createdConnectionId')) {
        self.connectionId = data.createdConnectionId;
      }
      if (data.hasOwnProperty('type') && data.type === 'paint' && data.connectionId !== self.connectionId) {
        _ref = data.cords;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          obj = _ref[_i];
          self.paintObjects.push(new PaintObject(obj.x, obj.y, self.currentColor));
        }
      }
    };
    self.socket.onclose = function() {
      console.log('close');
    };
  };
  self.setMouseDown = function(val) {
    self.mouseDown = val;
  };
  self.getMouseDown = function() {
    return self.mouseDown;
  };
  self.setCanvas = function() {
    self.canvas = $('.js-main-canvas');
    self.canvas[0].height = $(window).height();
    self.canvas[0].width = $(window).width();
    self.ctx = self.canvas[0].getContext('2d');
  };
  paint = function() {
    var obj, _i, _len, _ref;

    _ref = self.paintObjects;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      obj = _ref[_i];
      self.ctx.fillStyle = obj.color;
      self.ctx.fillRect(obj.x, obj.y, obj.size, obj.size);
    }
  };
  self.setFrameAnimation = function() {
    requestAnimFrame(self.setFrameAnimation);
    paint();
  };
  self.handleStroke = function(event) {
    var b, cordsArray, m, num, pointOne, pointTwo, y, _i, _ref, _ref1;

    if (self.lastY !== null && self.lastX !== null) {
      cordsArray = [];
      pointOne = [self.lastX, self.lastY];
      pointTwo = [event.clientX, event.clientY];
      m = (pointOne[1] - pointTwo[1]) / (pointOne[0] - pointTwo[0]);
      b = pointOne[1] - m * pointOne[0];
      for (num = _i = _ref = pointOne[0], _ref1 = pointTwo[0]; _ref <= _ref1 ? _i <= _ref1 : _i >= _ref1; num = _ref <= _ref1 ? ++_i : --_i) {
        y = m * num + b;
        if (m === -Infinity || m === Infinity || b === -Infinity || b === Infinity) {
          y = event.clientY;
        }
        self.paintObjects.push(new PaintObject(num, y, self.currentColor));
        cordsArray.push({
          x: num,
          y: y
        });
      }
      self.socket.send(JSON.stringify({
        type: 'paint',
        connectionId: self.connectionId,
        cords: cordsArray,
        color: self.currentColor
      }));
    }
    self.lastX = event.clientX;
    self.lastY = event.clientY;
  };
  self.setEventHandlers = function() {
    $(window).mousedown(function() {
      return self.setMouseDown(true);
    });
    $(window).mouseup(function() {
      self.setMouseDown(false);
      self.lastY = null;
      return self.lastX = null;
    });
    $(window).mousemove(function(event) {
      if (self.getMouseDown()) {
        return self.handleStroke(event);
      }
    });
  };
  self.construct();
};

$(function() {
  new PaintBoard();
});
