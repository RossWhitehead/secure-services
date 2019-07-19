var express = require('express')
var fs = require('fs')
var https = require('https')

var app = express()

var options = {
    key: fs.readFileSync(__dirname + '/certs/ica.key.pem'),
    cert: fs.readFileSync(__dirname + '/certs/ica.cert.pem'),
    ca: fs.readFileSync(__dirname + '/certs/ica-chain.cert.pem'),
    requestCert: true,
    rejectUnauthorized: false,
    passphrase: '****'
}

process.env.NODE_TLS_REJECT_UNAUTHORIZED = '0'

app.use(function (req, res, next) {
    const cert = req.connection.getPeerCertificate()
    if (req.client.authorized) {
        res.send(`Hello ${cert.subject.CN}, your certificate was issued by ${cert.issuer.CN}!`)
        next()
    } else if (cert.subject) {
        res.status(403)
            .send(`Sorry ${cert.subject.CN}, certificates from ${cert.issuer.CN} are not welcome here.`)
    } else {
        res.status(401)
            .send(`Sorry, but you need to provide a client certificate to continue.`)
    }
})

var listener = https.createServer(options, app).listen(4433, function () {
    console.log('Express HTTPS server listening on port ' + listener.address().port)
})
