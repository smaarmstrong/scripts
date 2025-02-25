sudo scutil --set HostName $(LC_ALL=C tr -dc 'a-zA-Z' </dev/urandom | head -c 8)
echo $(scutil --get HostName)
