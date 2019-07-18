# Intermediate CA
INAME=$1
ROOTDIR=root/ca
IDIR=$ROOTDIR/ica/$INAME

mkdir -p $IDIR
mkdir -p $IDIR/private
mkdir -p $IDIR/certs
mkdir -p $IDIR/crl
mkdir -p $IDIR/csr
mkdir -p $IDIR/newcerts

touch $IDIR/index.txt
echo 1000 > $IDIR/serial
echo 1000 > $IDIR/crlnumber

# ICA_DIR is subtitite value for the CA_default.dir config value
export ICA_DIR=$IDIR

# Gen intermediate private key
openssl genrsa -aes256 \
    -out $IDIR/private/ica.key.pem 4096

# Gen intermediate CSR
openssl req -config ica-openssl.conf -new -sha256 \
    -key $IDIR/private/ica.key.pem \
    -out $IDIR/csr/ica.csr.pem

# Gen intermediate cert
openssl ca -config ca-openssl.conf -extensions v3_intermediate_ca \
    -days 3650 -notext -md sha256 \
    -in $IDIR/csr/ica.csr.pem \
    -out $IDIR/certs/ica.cert.pem

# Gen cert chain
cat $IDIR/certs/ica.cert.pem $ROOTDIR/certs/ca.cert.pem > $IDIR/ica-chain.cert.pem