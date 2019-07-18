# Root CA
DIR=root/ca

mkdir -p $DIR
mkdir -p $DIR/private
mkdir -p $DIR/certs
mkdir -p $DIR/newcerts
mkdir -p $DIR/crl

touch $DIR/index.txt
echo 1000 > $DIR/serial

# Gen root private key
# 4096 bits for keys
openssl genrsa -aes256 -out $DIR/private/ca.key.pem 4096

# Gen root cert
# Long lived, 7300 days
openssl req -config ca-openssl.conf \
    -key $DIR/private/ca.key.pem \
    -new -x509 -days 7300 -sha256 -extensions v3_ca \
    -out $DIR/certs/ca.cert.pem