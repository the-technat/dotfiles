k3ddd () {
  sudo systemctl start docker
  # requires net-tools
  interface=$1
  name=$2
  if [[ $interface != "" ]]
  then
    IP=$(ifconfig $interface | grep inet | grep -v inet6 | awk '{print $2}')
    k3d cluster create $name -a 2 --api-port $IP:6550 -p 443:443@loadbalancer -p 80:80@loadbalancer -p 8080:8080@loadbalancer
  else
    echo "No network interface specified"
  fi
}

