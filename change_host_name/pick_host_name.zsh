#!/bin/zsh

print -n "Enter the new hostname (e.g., my-device): "
read new_hostname

if [[ -n "$new_hostname" ]]; then
  sudo sh -c "scutil --set HostName '$new_hostname.local'; scutil --set LocalHostName '$new_hostname'; scutil --set ComputerName '$new_hostname'"

  # Verify the changes
  echo "HostName changed to: $(scutil --get HostName)"
  echo "LocalHostName changed to: $(scutil --get LocalHostName)"
  echo "ComputerName changed to: $(scutil --get ComputerName)"

  # Suggest restarting mDNSResponder (optional)
  echo "You may need to restart mDNSResponder for the changes to take full effect."
  echo "Would you like to restart it now? (y/n)"
  read restart_mdns
  if [[ "$restart_mdns" == "y" ]]; then
    sudo killall -HUP mDNSResponder
    echo "mDNSResponder restarted."
  fi
else
  echo "Hostname change cancelled. No hostname provided."
fi
