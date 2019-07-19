var fs = require('fs')
var https = require('https')

var options = {
    host: 'localhost',
    port: 4433,
    key: fs.readFileSync('certs/client1.key.pem'),
    cert: fs.readFileSync('certs/client1.cert.pem'),
    ca: fs.readFileSync('certs/ica-chain.cert.pem'),
    passphrase: '****'
}

// A fudge to ignore hostname cert errors when service is running on localhost
process.env["NODE_TLS_REJECT_UNAUTHORIZED"] = 0

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
