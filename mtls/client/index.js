var fs = require('fs')
var https = require('https')

var options = {
    host: 'localhost',
    port: 4433,
    key: fs.readFileSync('certs/client-key.pem'),
    cert: fs.readFileSync('certs/client-crt.pem'),
    ca: fs.readFileSync('certs/ca-crt.pem'),
}

var req = https.request(options, function (res) {
    console.log("statusCode: ", res.statusCode)
    console.log("headers: ", res.headers)

    console.log("Server Host Name: " + res.connection.getPeerCertificate().subject.CN)

    res.on('data', function (d) {
        process.stdout.write(d)
    })
})

req.end()

req.on('error', function (e) {
    console.error(e)
})