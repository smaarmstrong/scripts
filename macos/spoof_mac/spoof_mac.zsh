#!/bin/zsh
# In order for this to work on new macs, you must disconnect from your network,
# but leave your Wi-Fi ON.

# Define the path to the file where the original MAC address will be stored
MAC_ADDRESS_FILE="./original_mac_address.txt"

# Function to get the current MAC address of en0
get_current_mac() {
  ifconfig en0 | awk '/ether/{print $2}'
}

# Function to generate a random MAC address
generate_random_mac() {
  local mac=$(openssl rand -hex 6 | sed 's/\(..\)/\1:/g; s/:$//')
  echo "$mac"
}

# Function to set the MAC address
set_mac_address() {
  sudo ifconfig en0 ether $1
}

# Check if the MAC address file exists
if [[ ! -f $MAC_ADDRESS_FILE ]]; then
  # Save the original MAC address if the file doesn't exist
  ORIGINAL_MAC=$(get_current_mac)
  echo "Saving original MAC address: $ORIGINAL_MAC"
  echo $ORIGINAL_MAC > $MAC_ADDRESS_FILE
else
  # Read the saved original MAC address
  ORIGINAL_MAC=$(cat $MAC_ADDRESS_FILE)
  echo "Original MAC address is: $ORIGINAL_MAC"
fi

# Prompt for user confirmation to revert to the original MAC address
echo "Do you want to revert to the original MAC address? (y/n): \c"
read REPLY
if [[ $REPLY =~ ^[Yy]$ ]]; then
  # Check if the current MAC address is different from the original
  CURRENT_MAC=$(get_current_mac)
  if [[ $CURRENT_MAC != $ORIGINAL_MAC ]]; then
    echo "Reverting to original MAC address: $ORIGINAL_MAC"
    set_mac_address $ORIGINAL_MAC
    echo "MAC address has been reverted to: $(get_current_mac)"
  else
    echo "Current MAC address is already the original one."
  fi
fi

# Prompt for user confirmation to change the MAC address
echo "Current MAC Address: $(get_current_mac)"
echo "Do you want to change the MAC address? (y/n): \c"
read REPLY
if [[ $REPLY =~ ^[Yy]$ ]]; then
  # Generate a new MAC address
  NEW_MAC=$(generate_random_mac)
  echo "Generated new MAC address: $NEW_MAC"
  
  # Change the MAC address
  set_mac_address $NEW_MAC
  
  echo "MAC address has been changed to: $(get_current_mac)"
else
  echo "MAC address change aborted by user."
fi
