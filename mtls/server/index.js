var express = require('express')
var fs = require('fs')
var https = require('https')

var app = express()

var options = {
    key: fs.readFileSync('certs/server-key.pem'),
    cert: fs.readFileSync('certs/server-crt.pem'),
    ca: fs.readFileSync('certs/ca-crt.pem'), 
    requestCert: true,                  
    rejectUnauthorized: false           
}

app.use(function (req, res, next) {
    if (!req.client.authorized) {
        return res.status(401).send('User is not authorized')
    }

    var cert = req.socket.getPeerCertificate()
    if (cert.subject) {
        console.log(cert.subject.CN)
    }
    next()
 })

app.use(function (req, res, next) {
    res.writeHead(200)
    res.end("hello world\n")
    next()
})

var listener = https.createServer(options, app).listen(4433, function () {
    console.log('Express HTTPS server listening on port ' + listener.address().port)
})