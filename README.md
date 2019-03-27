# BOOTSTRAP Repository

##init_telos.sh
This script is run on fresh Ubuntu (18.04) servers to install TELOS and configure
the server as either an API/P2P node or a producer node.

Use this init script to kickstart a new telos node.  Spin up a node with:
2 cpu, 32Gb ram, (2) 250Gb raw partitions for zfs, public IP (unless producer node)

Execute this command to kick things off:
apt-get install git -y && cd /root && git clone https://github.com/TelosGlobal/bootstrap.git && cd bootstrap && chown 775 ini_telos.sh

Then run this script:
/root/bootstrap/init_telos.sh

##minion_cfg.sed
This file is used by init_telos.sh to configure the salt minion config file.

##nginx_sample
Sample nginx file that can be copied and configured for the local SSL offload proxy.
Desired config is to install nginx on the NODE01 server and config to ssl offload and
load-balance API and P2P traffic between NODE01 and NODE02.
