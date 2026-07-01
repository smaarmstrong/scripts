#!/bin/zsh

# need a .env file with tkn=ghp_[rest of your token]
# delete .env after running

export tkn=$(cat .env | cut -d'=' -f2)
git remote set-url origin https://$tkn@github.com/lilrobo/CrateNFC.git
