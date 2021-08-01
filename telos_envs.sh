#Sets Telos specific environment variables
#Place this file in /etc/profile.d/

alias ls='ls --color=auto'
alias ll='ls -al --color=auto'

#Claimer Wallet ENVs
WALLET_PWD=NOTSETUP
export WALLET_PWD

#Send2Exchange ENVs
SEND2_WALLET=trx
export SEND2_WALLET
SEND2_FRACCT=telosglobal1
export SEND2_FRACCT
SEND2_WALLETKEY=NOTSETUP
export SEND2_WALLETKEY
SEND2_TOACCT=probitandtls
export SEND2_TOACCT
SEND2_MEMO=NOTSETUP
export SEND2_MEMO

