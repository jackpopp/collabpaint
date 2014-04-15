/*var net = require('net');

var server = net.createServer(function(socket){
	socket.write('Echo Server\n\r');
	socket.pipe(socket);
})

server.listen(3000, 'localhost');*/

var io = require('socket.io').listen(3000);

io.sockets.on('connection', function (socket) {
	io.sockets.emit('news', { will: 'be received by everyone'});
});