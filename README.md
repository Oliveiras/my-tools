# AROliveira's Command Line Tools

Self contained utilities to help common activities.

## Tools

Check the list of provided tools below.

### Certificate

Help to deal with TLS certificates using OpenSSL.

**Features:**
- Generate root CA certificate
- Generate child certificates
- Print certificate contents

## General instructions

All tools expect the options to be passed as program arguments using `getopts` format. Ex: `tool -x arg1 -y arg2`.

### Common options

- **-C**    Creates a new resource.
- **-R**    Reads a resource.
- **-U**    Updates a resource.
- **-D**    Deletes a resource.
- **-H**    Show help and exit.

