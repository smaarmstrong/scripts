#!/bin/zsh

print -n "Enter the new hostname: "
read new_hostname

if [[ -n "$new_hostname" ]]; then
  sudo scutil --set HostName "$new_hostname"
  echo "Hostname changed to: $(scutil --get HostName)"
else
  echo "Hostname change cancelled. No hostname provided."
fi
