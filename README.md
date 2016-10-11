# AppDynamics SSL Cert Utils

ATTENTION:
* These are **unofficial** utilities so consider them to be Beta--not GA. 
* Contact your AppDynamics account representative if you're unsure how to proceed with custom SSL certs.
* This is an author supported utility so don't open an official Support ticket. Please report any bugs via GitHub's integrated issue tracker.


## Description
Totally unofficial SSL utils to ease working with SSL certificates in AppD.

They're not a total replacement for keytool. Think of them as the **Basic** interface to Java keystores and keytool is the Advanced one. These utilities are meant to remove some of the friction around working with keytool and keystores. I've taken the most common functions and distilled them down to some basic commands for both the **Controller** and **EUM Server**.

1. Generate a certificate signing request
1. Import a signed cert
1. Import a root or intermediate cert
1. List the contents of keystore

## Download
Download the latest release from the Releases page:

https://github.com/derrekyoung/appd-ssl-cert-utils/releases/latest

## Usage
Always follow the official AppDynamics documentation at https://docs.appdynamics.com

There is a script that's specific to the Controller and one to the EUM Server. Choose the right one. Please report any bugs via GitHub's integrated issue tracker.

The basic flow is to
- Create a Certificate Signing Request (CSR)
- Send that CSR to your CA
- They'll send back to you a signed certificate
- You'll then need to import your signed certificate
- IF you have an internal CA, then you'll first need to import your root cert, cert chain and/or intermediate cert. The exact steps depend on your organization and environment.

### Controller usage
1. Verify the appropriate permissions on the script
1. Set the Controller home directory at the top of `controller-ssl-certs-util.sh`.
1. Run `./controller-ssl-certs-util.sh` and follow the interactive shell.

### EUM Server usage
1. Verify the appropriate permissions on the script
1. Set the EUM Server home directory at the top of `eum-ssl-certs-util.sh`.
1. Run  `./eum-ssl-certs-util.sh` and follow the interactive shell.
