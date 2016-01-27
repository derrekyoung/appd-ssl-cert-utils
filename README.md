# AppD-SSL-Cert-Utils

ATTENTION:
* These are **unofficial** utilities so consider them to be Beta--not GA. If unsure, bring in your AppDynamics representative.

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
Always follow the official AppDynamics documentation at https://docs.appdynamics.com

The basic flow is to
- Create a Certificate Signing Request (CSR)
- Send that CSR to your CA
- They'll send back to you a signed certificate
- You'll then need to import your signed certificate
- IF you have an internal CA, then you'll first need to import your root cert, cert chain and/or intermediate cert. The exact steps depend on your organization and environment.

Run either `./controller-ssl-certs-util.sh` or `./eum-ssl-certs-util.sh` and then use the interactive command line. No parameters are passed in.
