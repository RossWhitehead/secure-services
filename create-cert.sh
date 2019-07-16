# Intermediate CA
ICA_NAME=$1
SERVICE_NAME=$2

ICA_DIR=root/ca/ica/$ICA_NAME

# Gen intermediate private key
openssl genrsa -aes256 \
    -out $ICA_DIR/private/$SERVICE_NAME-key.pem 2048

# Gen intermediate CSR
openssl req -config ica-openssl.conf -new -sha256 \
    -key $ICA_DIR/private/$SERVICE_NAME-key.pem \
    -out $ICA_DIR/csr/$SERVICE_NAME-csr.pem

# Gen intermediate cert
openssl ca -config ca-openssl.conf -extensions server_cert \
    -days 375 -notext -md sha256 \
    -in $ICA_DIR/csr/$SERVICE_NAME-csr.pem \
    -out $ICA_DIR/certs/$SERVICE_NAME-cert.pem
