# secure-services
Playing around with securing services

## Creating certs
Scripts are inspired by the following guide

https://jamielinux.com/docs/openssl-certificate-authority/index.html

### Create CA
Creates key and cert for a root CA
```
bash create-ca.sh
```
Performs the the following:
* Creates a root/ca directory
* Creates a CA database, used to track certificates
    * index.txt and serial files
    * used to track certificates
* Generate a CA private key
    * private/ca.key.pem
    * 4096 bits is used for signing root and intermidiate CA keys. Client are server keys are 2048 for performance reasons.
* Generate a CA cert
    * certs/ca.cert.pem 
    * Long lived, valid for 7300 days.
    * Utilises defaults from ca-openssl.conf

#### Verify CA cert
```
openssl x509 -noout -text -in root/ca/certs/ca.cert.pem
```
Of note:
* ```Signiture algorithm``` is sha256WithRSAEncryption
* ```Validity``` is for 20 years
* ```Public key``` is 4096 bit
* Cert is self-signed so ```Subject``` and ```Issuer``` are identical

### Create ICA
Creates key and cert for an intermediary CA, based on the aforementioned CA
```
ICA_NAME=myICA
bash create-ica.sh $ICA_NAME
```
Performs the the following -
* Creates a root/ca/ica/ICA_NAME directory
* Creates a intermediate CA database, used too track certificates
    * index.txt and serial files
* Generate a intermediate CA private key
    * private/ica.key.pem
    * 4096 bits is used for signing root and intermidiate CA keys. Client are server keys are 2048 for performance reasons.
* Generate a intermediate CA certificate signing request
    * csr/ica.csr.pem
    * Utilises defaults from ica-openssl.conf 
        * The statement ```export ICA_DIR=$IDIR``` is required to set the CA_default.dir value in the ica-openssl.conf file to the root/ca/ica/ICA_NAME directory.
* Generate a intermedate CA cert
    * certs/ica.cert.pem 
    * Long lived, valid for 3650 days.
    * Utilises defaults from ca-openssl.conf
* Creates a intermediate CA cert chain
    * ica-chain.cert.pem

#### Verify ICA cert
```
openssl x509 -noout -text \
    -in root/ca/ica/$ICA_NAME/certs/ica.cert.pem
```
Of note:
* ```Signiture algorithm``` is sha256WithRSAEncryption
* ```Validity``` is for 10 years
* ```Public key``` is 4096 bit
* ```Issuer``` is the CA

### Create Client/Server Cert
Creates key and cert for a client or service based on an intermediary CA
```
ICA_NAME=myICA
CLIENT_NAME=myClient
bash create-client-cert.sh $ICA_NAME $CLIENT_NAME
```
```
ICA_NAME=myICA
SERVER_NAME=myServer
bash create-server-cert.sh $ICA_NAME $SERVER_NAME
```
The scripts are identical apart from the extensions added when generating the cert: ```-extensions usr_cert``` adds the clientAuth extended key extension; ```-extensions server_cert``` adds the serverAuth extended key.

Performs the the following (substitute server for client where appropriate) -
* Adds all items to the root/ca/ica/ICA_NAME directory
* Generates a client private key
    * private/CLIENT_NAME.key.pem
    * 2048 bits is used for signing the key.
* Generate a client certificate signing request
    * csr/CLIENT_NAME.csr.pem
    * Utilises defaults from ica-openssl.conf 
        * The statement ```export ICA_DIR=$IDIR``` is required to set the CA_default.dir value in the ica-openssl.conf file to the root/ca/ica/ICA_NAME directory.
* Generate a client cert
    * certs/CLIENT_NAME.cert.pem 
    * Short lived, valid for 375 days (1 year + 10 days grace).
    * Utilises defaults from ica-openssl.conf 

#### Verify client/server cert
```
openssl x509 -noout -text \
    -in root/ca/ica/$ICA_NAME/certs/$CLIENT_NAME.cert.pem
```
```
openssl x509 -noout -text \
    -in root/ca/ica/$ICA_NAME/certs/$SERVER_NAME.cert.pem
```
Of note:
* ```Signiture algorithm``` is sha256WithRSAEncryption
* ```Validity``` is for 375 days
* ```Public key``` is 2048 bit
* ```Issuer``` is the ICA
* ```X509v3 Extended Key Usage``` equals TLS Web Client Authentication or TLS Web Server Authentication

### Renewing client/server cert
To ensure minimal disruption in service it is convenient to be able to renew a certificate without having to revoke the existing certificate, whether it be expired or not. 

Renewing a certificate involves generating a new CSR for an existing subject, (specifically DN), and then processing the request. There is some debate as to whether the existing private key should be used for cerfificate renewal or whether a new one should be generated. If you are happy to process a new private key then the ```create-client-cert.sh``` and ```create-server-cert.sh``` scripts can be used to renew a certificate.

To enable this I have added the ```unique_subject=no``` attribute to the ica-openssl.conf file.

Without this attribute, the certficate renewal would fail with the following error:

```
failed to update database
TXT_DB error number 2
```
