#Adds github perms

. scripts/.secret

git remote set-url origin https://$GITUSER:$GITPASS@github.com/TelosGlobal/salt_scripts.git

git remote set-url origin https://$GITUSER:$GITPASS@github.com/TelosGlobal/bootstrap.git
