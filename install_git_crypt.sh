#This script installs git-crypt

cd /tmp
git clone https://github.com/AGWA/git-crypt.git
cd git-crypt
make
make install PREFIX=/usr/local
cd /root/bootstrap/
echo "git-crypt installed.  Copy key file here and run:"
echo "git-crypt unlock cryptkey"
echo "DELETE cryptkey file when done!"


