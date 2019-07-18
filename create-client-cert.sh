# Server cert
ICA_NAME=$1
SERVICE_NAME=$2

# ICA_DIR is subtitite value for the CA_default.dir config value
export ICA_DIR=root/ca/ica/$ICA_NAME

# Gen intermediate private key
openssl genrsa -aes256 \
    -out $ICA_DIR/private/$SERVICE_NAME.key.pem 2048

# Gen intermediate CSR
openssl req -config ica-openssl.conf -new -sha256 \
    -key $ICA_DIR/private/$SERVICE_NAME.key.pem \
    -out $ICA_DIR/csr/$SERVICE_NAME.csr.pem

# Gen intermediate cert
openssl ca -config ica-openssl.conf -extensions usr_cert \
    -days 375 -notext -md sha256 \
    -keyfile $ICA_DIR/private/ica.key.pem \
    -cert $ICA_DIR/certs/ica.cert.pem \
    -in $ICA_DIR/csr/$SERVICE_NAME.csr.pem \
    -out $ICA_DIR/certs/$SERVICE_NAME.cert.pem
