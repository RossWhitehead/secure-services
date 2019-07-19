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
bash create-ica.sh <ica name>
```
Performs the the following -
* Creates a root/ca/ica/\<ica name> directory
* Creates a intermediate CA database, used too track certificates
    * index.txt and serial files
* Generate a intermediate CA private key
    * private/ica.key.pem
    * 4096 bits is used for signing root and intermidiate CA keys. Client are server keys are 2048 for performance reasons.
* Generate a intermediate CA certificate signing request
    * csr/ica.csr.pem
    * Utilises defaults from ica-openssl.conf 
        * The statement ```export ICA_DIR=$IDIR``` is required to set the CA_default.dir value in the ica-openssl.conf file to the root/ca/ica/\<ica name> directory.
* Generate a intermedate CA cert
    * certs/ica.cert.pem 
    * Long lived, valid for 3650 days.
    * Utilises defaults from ca-openssl.conf
* Creates a intermediate CA cert chain
    * ica-chain.cert.pem

#### Verify ICA cert
```
openssl x509 -noout -text \
    -in root/ca/ica/<ica name>/certs/ica.cert.pem
```
Of note:
* ```Signiture algorithm``` is sha256WithRSAEncryption
* ```Validity``` is for 10 years
* ```Public key``` is 4096 bit
* ```Issuer``` is the CA

### Create Client/Server Cert
Creates key and cert for a client or service based on an intermediary CA
```
bash create-client-cert.sh <ica name> <client name>
```
```
bash create-server-cert.sh <ica name> <server name>
```
The scripts are identical apart from the extensions added when generating the cert: ```-extensions usr_cert``` adds the clientAuth extended key extension; ```-extensions server_cert``` adds the serverAuth extended key.

Performs the the following (substitute client for server name where appropriate) -
* Adds all items to the root/ca/ica/\<ica name> directory
* Generate a server private key
    * private/\<server name>.key.pem
    * 2048 bits is used for signing the server key.
* Generate a server certificate signing request
    * csr/\<server name>.csr.pem
    * Utilises defaults from ica-openssl.conf 
        * The statement ```export ICA_DIR=$IDIR``` is required to set the CA_default.dir value in the ica-openssl.conf file to the root/ca/ica/\<ica name> directory.
* Generate a server cert
    * certs/\<server name>.cert.pem 
    * Short lived, valid for 375 days (1 year + 10 days grace).
    * Utilises defaults from ica-openssl.conf 

#### Verify client/server cert
```
openssl x509 -noout -text \
    -in root/ca/ica/<ica name>/certs/<service name>.cert.pem
```
Of note:
* ```Signiture algorithm``` is sha256WithRSAEncryption
* ```Validity``` is for 375 days
* ```Public key``` is 2048 bit
* ```Issuer``` is the ICA
* ```X509v3 Extended Key Usage``` equals TLS Web Client Authentication or TLS Web Server Authentication
