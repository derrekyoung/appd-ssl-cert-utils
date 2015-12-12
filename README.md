# AppD-SSL-Cert-Utils

ATTENTION: 
* These are **unofficial** utilities so consider them to be Beta--not GA
* Your mileage may vary
* Thar be dragons
* Etcetera, etcetera

## Description
Totally unofficial SSL utils to ease working with SSL certificates in AppD.

They're not a total replacement for keytool. Think of them as the **Basic** interface to Java keystores and keytool is the Advanced one. These utilities are meant to remove some of the friction around working with keytool and keystores. I've taken the most common functions and distilled them down to some basic commands for both the **Controller** and **EUM Server**.

1. Generate a certificate signing request
1. Import a signed cert
1. Import a root or intermediate cert
1. List the contents of keystore

## Download
Download the latest release from the Releases page:

https://github.com/derrekyoung/AppD-SSL-Cert-Utils/releases/latest

## Usage
Run either `./controller-ssl-certs-util.sh` or `./eum-ssl-certs-util.sh` and then use the interactive command line. 

No parameters are passed in. Always follow the official AppDynamics documentation. In general, you'll need to create a CSR and then import the cert. If you have an internal CA, you'll need to import the root and/or intermediate certs.
