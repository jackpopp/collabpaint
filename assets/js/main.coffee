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
	self.socket = null
	self.connectionId = null

	self.construct = ->
		self.setCanvas()
		self.setEventHandlers()
		self.setFrameAnimation()

		self.socket = new SockJS('/echo');

		###
		self.socket.onopen = (e) ->
			self.connectionId = e
			console.log e
			return
		###

		self.socket.onmessage = (e) ->
			data = JSON.parse(e.data)
			if data.hasOwnProperty('createdConnectionId')
				self.connectionId = data.createdConnectionId
			if data.hasOwnProperty('type') and data.type is 'paint' and data.connectionId isnt self.connectionId
				for obj in data.cords
					self.paintObjects.push new PaintObject(obj.x, obj.y, self.currentColor)
			return

		self.socket.onclose = ->
			console.log('close')
			return

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
		# credit u/jasonbar @http://stackoverflow.com/questions/2441362/php-find-coordinates-between-two-points
		if self.lastY isnt null and self.lastX isnt null
			cordsArray = []
			pointOne = [self.lastX, self.lastY]
			pointTwo = [event.clientX, event.clientY]
			m = ( (pointOne[1] - pointTwo[1]) / (pointOne[0] - pointTwo[0]) )
			b = pointOne[1] - m * pointOne[0]
			for num in [pointOne[0]..pointTwo[0]]
				y = m*num+b
				if m is -Infinity or m is Infinity or b is -Infinity or b is Infinity 
					y = event.clientY
				self.paintObjects.push new PaintObject(num, y, self.currentColor)
				cordsArray.push {x: num, y: y}

			# send array of cords, connection id and colour
			self.socket.send( JSON.stringify({type: 'paint', connectionId: self.connectionId, cords: cordsArray, color: self.currentColor}) );

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
	return