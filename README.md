# BOOTSTRAP Repository

## init_telos.sh
This script is run on fresh Ubuntu (18.04) servers to install TELOS and configure
the server as either an API/P2P node or a producer node.

Use this init script to kickstart a new telos node.  Spin up a node with:
2 cpu, 32Gb ram, (2) 250Gb raw partitions for zfs, public IP (unless producer node)

### HTTPS METHOD
Execute this command to kick things off:

`apt-get install git -y && cd /root && git clone https://github.com/TelosGlobal/bootstrap.git && cd /root/bootstrap/ && chown 775 /root/bootstrap/init_telos.sh`

### SSH METHOD
On the new Linux server, create an SSH Keypair:

`ssh-keygen'
Hit Enter to take all defaults (default folder and no passphrase)

Copy the Public Key:
`cat /root/.ssh/id_rsa.pub`

Add the new public key to your GitHub key list:
`https://github.com/settings/keys`

Back on the new Linux server:
`apt-get install git -y && cd /root && git clone git@github.com:TelosGlobal/bootstrap.git && cd /root/bootstrap/ && chown 775 /root/bootstrap/init_telos.sh`

## Continue with the install:
Then run this script:

`/root/bootstrap/init_telos.sh`

##Git Push via SSH (Must save local SSH keys to github first)
`git push git@github.com:TelosGlobal/bootstrap master`

## To make sure git repo is set correctly
`git remote set-url origin https://<USERNAME>:<PASSWORD>@github.com/path/to/repo.git`

## git_crypt
To install git_crypt, perform the following steps:
- run the `install_git_crypt.sh` script
- Push the cryptkey file from the salt server (`push_cryptkey.sh`)
- Run `git-crypt unlock cryptkey`
- DELETE cryptkey file

## minion_cfg.sed
This file is used by `init_telos.sh` to configure the salt minion config file.

## nginx_sample
Sample nginx file that can be copied and configured for the local SSL offload proxy.
Desired config is to install nginx on the NODE01 server and config to ssl offload and
load-balance API and P2P traffic between NODE01 and NODE02.

## Setup ssh root keys
From the SALT server as ROOT type:

`cat ~/.ssh/id_rsa.pub | ssh username@server.address.com 'cat >> ~/.ssh/authorized_keys'`
