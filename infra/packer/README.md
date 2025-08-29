# Packer to create AMI on AWS

This packer is used to create AMI on AWS. It will install pritunl VPN on the AMI.

##  1. <a name='TableofContents'></a>Table of Contents
<!-- vscode-markdown-toc -->
* 1. [Table of Contents](#TableofContents)
* 2. [Prerequisites](#Prerequisites)
* 3. [How to use](#Howtouse)
	* 3.1. [Build AMI](#BuildAMI)

<!-- vscode-markdown-toc-config
	numbering=true
	autoSave=true
	/vscode-markdown-toc-config -->
<!-- /vscode-markdown-toc -->

##  2. <a name='Prerequisites'></a>Prerequisites

- [Packer](https://www.packer.io/downloads)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)

##  3. <a name='Howtouse'></a>How to use

###  3.1. <a name='BuildAMI'></a>Build AMI


```bash
# set aws credentials using access key and secret key
export AWS_ACCESS_KEY_ID=your_access_key
export AWS_SECRET_ACCESS_KEY=your_secret_key
# set aws credentials using profile
export AWS_PROFILE=your_profile

# set aws region
export AWS_DEFAULT_REGION=your_region

# build AMI using packer
cd packer
packer build vpn.json
```

It will create an instance on AWS and install pritunl VPN on it. After that, it will create an AMI from the instance. The AMI will be tagged with defined tags in `vpn.json` file and will be used to create VPN instance through terraform.
