var port = process.env.PORT || 8080;
var express = require('express');
var app = express();
var server = app.listen(port);
var sockjs = require('sockjs');

var connections  = [];
var paintObjects = [];

app.engine('html', require('ejs').renderFile);

app.use('/assets', express.static(__dirname + '/assets'));

app.get('/', function(req, res){
	res.render('./index.html');
});

var echo = sockjs.createServer();
echo.on('connection', function(conn) {

	// create connection id, save in connections and send back to client
	connections[conn.id] = conn;
	conn.write( JSON.stringify({createdConnectionId: conn.id, currentPaintObjects: paintObjects}) );

    conn.on('data', function(message) {
    	// check if connection id exists, if it does regiser the paint object and send to all clients
    	data = JSON.parse(message)
    	if (data.hasOwnProperty('connectionId'))
    	{
            for (id in data.cords)
               paintObjects.push(data.cords[id]);

    		for (id in connections)
    			connections[id].write(message);
    	}
    });
    conn.on('close', function() {});
});

echo.installHandlers(server, {prefix:'/echo'});