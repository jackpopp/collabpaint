var port = 8080;
var express = require('express');
var app = express();
var server = app.listen(port);
var sockjs = require('sockjs');

var connections  = {};
var paintObjects = {};

app.engine('html', require('ejs').renderFile);

app.use('/assets', express.static(__dirname + '/assets'));

app.get('/', function(req, res){
	res.render('./index.html');
});

var echo = sockjs.createServer();
echo.on('connection', function(conn) {
    conn.on('data', function(message) {
        conn.write(message);
    });
    conn.on('close', function() {});
});

echo.installHandlers(server, {prefix:'/echo'});