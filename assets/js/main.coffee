window.requestAnimFrame = ( ->
  return  window.requestAnimationFrame       ||
          window.webkitRequestAnimationFrame ||
          window.mozRequestAnimationFrame    ||
          ( callback ) ->
            window.setTimeout(callback, 1000 / 60);

)();

PaintObject = (x, y, color) ->
	self = @
	self.x = x
	self.y = y
	self.color = color
	self.size = 10
	return

PaintBoard = ->
	self = @
	canvas = null
	self.ctx = null
	self.currentColor = 'black'
	self.paintObjects = []
	self.mouseDown = false
	self.lastX = null
	self.lastY = null

	self.construct = ->
		self.setCanvas()
		self.setEventHandlers()
		self.setFrameAnimation()
		return

	self.setMouseDown = (val) ->
		self.mouseDown = val
		return

	self.getMouseDown = -> 
		return self.mouseDown

	self.setCanvas = ->
		self.canvas = $('.js-main-canvas')
		self.canvas[0].height = $(window).height()
		self.canvas[0].width = $(window).width()
		self.ctx = self.canvas[0].getContext('2d')
		return

	paint = ->
		for obj in self.paintObjects
			self.ctx.fillStyle = obj.color
			self.ctx.fillRect(obj.x,obj.y,obj.size,obj.size)
		return

	self.setFrameAnimation = ->
		requestAnimFrame(self.setFrameAnimation)
		paint()
		return

	self.handleStroke = (event) ->
		###
		credit u/jasonbar @http://stackoverflow.com/questions/2441362/php-find-coordinates-between-two-points
		$pt1 = array(0, 0);
		$pt2 = array(10, 10);
		$m = ($pt1[1] - $pt2[1]) / ($pt1[0] - $pt2[0]);
		$b = $pt1[1] - $m * $pt1[0];

		for ($i = $pt1[0]; $i <= $pt2[0]; $i++)
		    $points[] = array($i, $m * $i + $b);
		###
		if self.lastY isnt null and self.lastX isnt null
			pointOne = [self.lastX, self.lastY]
			pointTwo = [event.clientX, event.clientY]
			m = ( (pointOne[1] - pointTwo[1]) / (pointOne[0] - pointTwo[0]) )
			b = pointOne[1] - m * pointOne[0]
			for num in [pointOne[0]..pointTwo[0]]
				y = m*num+b
				if m is -Infinity or m is Infinity or b is -Infinity or b is Infinity 
					y = event.clientY
				self.paintObjects.push new PaintObject(num, y, self.currentColor)
		self.lastX = event.clientX
		self.lastY = event.clientY
		return

	self.setEventHandlers = ->
		$(window).mousedown -> self.setMouseDown(true)
		$(window).mouseup -> 
			self.setMouseDown(false)
			self.lastY = null
			self.lastX = null
		$(window).mousemove (event) -> self.handleStroke(event) if self.getMouseDown()
		return

	self.construct()

	return

$ ->
	new PaintBoard()
	socket = io.connect('http://localhost:3000');
	socket.on('news', (data) ->
		console.log(data);
	);