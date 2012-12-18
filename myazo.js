var port = 3000;
var folder = './img';
var host = 'http://localhost';

var path = require('path');
var express = require('express');
var app = express();
var formidable = require('formidable');
var fs = require('fs');

var form = new formidable.IncomingForm();
form.uploadDir = folder;

app.get('/img/*', function(req, res){
	var id;

	if(req.originalUrl.length > 0){
		id = req.originalUrl.replace('/img/', '');
	}

	var filename = path.join(folder, id);

	res.set('Content-Type', 'image/png');
	res.status(200).sendfile(filename);
});

app.get('/*', function(req, res){
	var id;

	if(req.originalUrl.length > 0){
		id = req.originalUrl.substr(1);
	}

	console.log(id);

	var body = '<img src="' + host;

	if(port != 80){
		body += ':' + port;
	}

	body += '/img/' + id + '"/>';
	res.set('Content-Type', 'text/html');
	res.set('Content-Length', body.length);
	res.end(body);
});

app.post('/post', function(req, res){
	form.parse(req, function(err, fields, files){
		var id = path.basename(files.imagedata.path);

		var body = host;

		if(port != 80){
			body += ':' + port;
		}

		body += '/' + id;

		res.set('Content-Type', 'text/plain');
		res.set('Content-Length', body.length);
		res.end(body);
    });	
});

app.listen(port);
console.log('Listening on port http://localhost:' + port);