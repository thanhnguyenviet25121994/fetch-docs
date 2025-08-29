#cloud-config
repo_update: true
repo_upgrade: all

system_info:
  default_user:
    name: ${ssh_user}

users:
  - default
  - name: ${user}
    gecos: ${project_name} ${user}
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: users, admin
    ssh_import_id: None
    lock_passwd: true

packages:
  - tmux
  - git
  - wget
  - nc

write_files:
- content: |
    PRJNAME=${hostname}
    HOST=$PRJNAME-$(hostname -I|awk '{print $1}')
    if [ "$EUID" = "0" ] ; then
      PS1='\[\033[01;31m\]$HOST\[\033[01;34m\] \W \$\[\033[00m\] '
    else
      PS1='\[\033[01;${prompt_color}\]\u@$HOST\[\033[01;34m\] \W \$\[\033[00m\] '
    fi
  path: /etc/profile.d/ps1.sh
runcmd:
  - set -ex
  - sudo apt-get update -y
  - echo "1234567890"
  - sudo apt-get install -y docker.io docker-compose nginx  
  - sudo service docker start
  - sudo usermod -a -G docker ubuntu
  - sudo apt install nodejs git -y

