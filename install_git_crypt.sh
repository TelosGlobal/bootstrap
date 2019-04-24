#This script installs git-crypt

cd /tmp
git clone https://github.com/AGWA/git-crypt.git
cd git-crypt
make
make install PREFIX=/usr/local
cd /root/bootstrap/
echo "git-crypt installed.  Copy key file here and run:"
echo ""
echo "git-crypt unlock cryptkey"
echo ""
echo "Notes:"
echo "If needed to manually decrypt a file, use:"
echo "cat overly-encrypted-file | git-crypt smudge > unencrypted-version"
echo ""
echo "DELETE cryptkey file when done!"


