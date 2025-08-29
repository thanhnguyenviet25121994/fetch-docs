#+title: README
## Install & Config tools

### 1. Install on LocalStation

- **aws-cli/2.2.36 Python/3.8.8**

```bash
pip --version
python --version
sudo apt-get install awscli
aws --version
pip install awscli --upgrade --user
```

- **terraform v1.7.5**

```bash
wget https://releases.hashicorp.com/terraform/1.7.5/terraform_1.7.5_linux_amd64.zip
mkdir /bin/terraform
unzip terraform_1.7.5_linux_amd64.zip -d /usr/local/bin/terraform
terraform --version
```