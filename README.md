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
Generates the following in the root/ca directory -
* CA private key
    * private/ca.key.pem
    * 4096 bits is used for signing root and intermidiate CA keys. Client are server keys are 2048 for performance reasons.
* CA cert
    * certs/ca.cert.pem 
    * Long lived, valid for 7300 days.
    * Utilises defaults from ca-openssl.conf

### Create ICA
Creates key and cert for an intermediary CA, based on the aforementioned CA
```
bash create-ica.sh <ica name>
```

### Create Client/Server Cert
Creates key and cert for a client or service based on an intermediary CA
```
bash create-cert.sh <ica name> <client/server name>
```
