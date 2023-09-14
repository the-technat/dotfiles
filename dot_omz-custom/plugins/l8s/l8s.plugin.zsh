l8s() {
  
  if (( $# == 0 )); then
		cat >&2 <<'EOF'
Usage: l8s [create|tools|list|delete] <clusterName> 
Note: the script doesn't need elevated privileges in general, but some commands try to use sudo
EOF
	fi

	# quickly check if all deps are met
	dockerPath=$(which docker)
	k3dPath=$(which k3d)
	kubectlPath=$(which kubectl)
	
	if [[ "$kubectlPath" == "" ]] || [[ "$k3dPath" == "" ]] || [[ "$dockerPath" == "" ]]; then
		echo "Not all requirements for l8s are met"
		echo "Please ensure you have docker,k3d and kubectl installed and in your PATH"
		return
	fi

	systemctl is-active --quiet docker
	if [[ ! $? -eq 0 ]]; then
		sudo systemctl start docker 
		# ignore any non-zero exit codes
	fi 

	usersInDockerGroup=$(getent group docker | cut -d ":" -f 4)
	if [[ ! $usersInDockerGroup == *"$USER"* ]]; then
		echo "$USER is not in the docker group"	
		return
	fi
	
	case "$1" in
		(create)
			createCluster $2;;
		(tools)
			toolChain $2;;
		(list)
			k3d cluster list;;
		(delete)
			deleteCluster $2;;
		(*)
			;;
		esac
}


deleteCluster() {
  if [[ $1 == "" ]]; then
		echo "No name for the cluster specified"
		return
	fi
  k3d cluster delete $1
  docker network rm $1
}

createCluster() {
	
	# function creates a k3d cluster in a new docker bridge network
 	# the gateway of this network serves as the control-plane endpoint 
  # as well as the endpoint for traefik

	if [[ $1 == "" ]]; then
		echo "No name for the cluster specified"
		return
	fi
	echo "Creating new Cluster $1"
	
	# Create a new bridge network, rely on dockerd to assign a free IP range
	# Grab the IP range + the gateway (which is rechable from the host)
	if [[ $(docker network list |grep $1) = "" ]]; then
		docker network create $1
	else
		echo "Docker network $1 already exists"
		return
	fi
	
	subnet=$(docker network inspect $1 |  jq '.[0].IPAM.Config[0].Subnet'| tr -d "\"")
	gateway=$(docker network inspect $1 |  jq '.[0].IPAM.Config[0].Gateway' |tr -d "\"")

	name="$(date +%s)config.yaml"
  cat > /tmp/$name <<EOF
apiVersion: k3d.io/v1alpha5
kind: Simple
metadata:
  name: $1
servers: 1
agents: 2
kubeAPI:
  hostIP: "$gateway"
  hostPort: "6443"
network: $1
ports:
- port: $gateway:80:80
  nodeFilters:
  - loadbalancer
- port: $gateway:443:443
  nodeFilters:
  - loadbalancer
hostAliases:
  - ip: $gateway
    hostnames:
      - $1.local
EOF
  k3d cluster create --config /tmp/$name
	if [[ ! $? -eq 0 ]]; then
		# if the cluster creation failed, we rollback the network too
		docker network rm $1
		rm /tmp/$name
		return
	fi
  rm /tmp/$name

  echo "Created cluster $1 with control-plane available at $gateway:6443 and LoadBalancer available at $gateway:443"
}

toolChain() {
  if [[ $1 == "" ]]; then
		echo "No name for the cluster specified"
		return
	fi

	helmPath=$(which helm)
	goTemplateCLI=$(which tpl)
	if [[ "$helmPath" == "" ]] || [[ "$j2Path" == "" ]]; then
		echo "Not all requirements met for installing the toolchain" 
		echo "Please ensure you have helm and go-template-cli installed and in your PATH"
		return
	fi

	echo "Installing toolchain on $1"
	# Installation must be reproducable, so that a rerun just reconfigured the tools

	## Argo CD
	kubectl create ns argocd
  containsRepo=$(helm repo list |grep argo)
  if [[ $containsRepo == "" ]]
  then
    helm repo add argo https://argoproj.github.io/argo-helm
  fi
	tpl -f $HOME/.omz_custom/plugins/l8s/argocd-values.yaml > $(pwd)/argocd-values.yaml
	echo "Argo CD values have been saved into your current directroy"
  #helm upgrade -i -n argocd argocd argo/argo-cd -f $(pwd)/argocd-values.yaml
  #echo "Waiting for Argo CD server to become available..."
  #sleep 2
  #pod=$(kubectl get pods -l "app.kubernetes.io/name=argocd-server" -n argocd -o=jsonpath='{.items[0].metadata.name}')
  #kubectl wait -n argocd --timeout=600s --for=condition=Ready pod/$pod
  #sleep 2
  #echo "Argo CD UI at https://argocd.local using user admin and password $(getArgoAdminPW)"

  #kubectl patch -n argocd cm argocd-cmd-params-cm --patch '{"data": {"server.insecure": "true"}}'
  #kubectl rollout -n argocd restart deployment argocd-server
  cat <<EOF | kubectl apply -n argocd -f -
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      name: argocd-server
      namespace: argocd
      labels:
        app.kubernetes.io/component: server
        app.kubernetes.io/name: argocd-server
        app.kubernetes.io/part-of: argocd
      annotations:
        ingress.kubernetes.io/ssl-redirect: "true"
    spec:
      rules:
      - host: argocd.local
        http:
          paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: argocd-server
                port:
                  number: 80
EOF

# deployes Dex using official helm chart
# and preconfigured config this dir
# note: won't work if you omit
# pass those into the function
  #id=$1
  #secret=$2
  #kubectl create ns dex
  #containsRepo=$(helm repo list |grep dex)
  #if [[ $containsRepo == "" ]]
  #then
  #  helm repo add dex https://chart.dexidp.io
  #fi
  #helm upgrade -i -n dex dex dex/dex -f $HOME/.zsh-custom/plugins/argocd/dex-values.yaml --set 'config.connectors[0].config.clientID'=$id --set 'config.connectors[0].config.clientSecret'=$secret
 #clientID and clientSecret

 

  #kubectl wait -n argocd --for=jsonpath='{.kind}'=Secret secret/argocd-initial-admin-secret
  #pw=$(kubectl -n argocd get secrets argocd-initial-admin-secret -o jsonpath='{.data.password}' |base64 -d)
  #echo $pw
}
