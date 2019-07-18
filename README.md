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
Performs the the following -
* Creates a root/ca directory
* Creates a CA database
    * root/ca/index.txt and root/ca/serial files
    * used to track certificates
* Generate a CA private key
    * private/ca.key.pem
    * 4096 bits is used for signing root and intermidiate CA keys. Client are server keys are 2048 for performance reasons.
* Ganerate a CA cert
    * root/ca/certs/ca.cert.pem 
    * Long lived, valid for 7300 days.
    * Utilises defaults from ca-openssl.conf

### Create ICA
Creates key and cert for an intermediary CA, based on the aforementioned CA
```
bash create-ica.sh <ica name>
```
Performs the the following -
* Creates a root/ca/ica/\<ica name> directory
* 
---
*Note*

The statement ```export ICA_DIR=$IDIR``` is required to set the CA_default.dir value in the ica-openssl.conf file to the /<ica name> directory.
---

### Create Client/Server Cert
Creates key and cert for a client or service based on an intermediary CA
```
bash create-cert.sh <ica name> <client/server name>
```
