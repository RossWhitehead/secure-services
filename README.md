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
