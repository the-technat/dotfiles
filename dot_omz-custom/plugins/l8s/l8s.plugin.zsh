l8s() {
  
    if (( $# == 0 )); then
      cat >&2 <<'EOF'
Usage: l8s [create|tools|list|delete] <clusterName>
Note: the function does need elevated privileges in some commands (e.g sudo)
EOF
    fi

    # quickly check if all deps are met
    dockerPath=$(which docker)
    k3dPath=$(which k3d)
    kubectlPath=$(which kubectl)
    hostessPath=$(which hostess)

    if [[ ! -f "$hostessPath" ]]; then
        echo "Please install hostess"
        echo "https://github.com/cbednarski/hostess"
        return
    fi  

    if [[ ! -f "$kubectlPath" ]]; then
        echo "Please install kubectl"
        echo "https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/"
        return
    fi

    if [[ ! -f "$k3dPath" ]]; then
        echo "Please install k3d"
        echo "https://k3d.io/"
    fi

    if [[ ! -f "$dockerPath" ]]; then
        echo "Please install docker"
        echo "https://docs.docker.com/engine/install/"
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
          helmPath=$(which helm)
          goTemplateCLIPath=$(which tpl)
          if [[ ! -f "$helmPath" ]]; then
            echo "Please install helm"
            echo "https://helm.sh/docs/intro/install/"
            return
          fi
          if [[ ! -f "$goTemplateCLIPath" ]]; then
            echo "Please install go-template-cli"
            echo "https://github.com/bluebrown/go-template-cli"
            return
          fi
          toolChain $2
          ;;
        (list)
            k3d cluster list;;
        (delete)
            deleteCluster $2;;
        (*)
            ;;
        esac
}

deleteCluster() {
  checkClusterName $1

  kubectl delete ingress --all-namespaces --all
  sleep 5
  kubectl delete namespace tailscale
  sleep 5
  k3d cluster delete $1
  docker network rm $1
  sudo hostess rm $1.local 
}

createCluster() {
    # function creates a k3d cluster in a new docker bridge network
    # the gateway of this network serves as the control-plane endpoint as well as the endpoint for traefik (80/443)
    # thus the cluster is network-wise fully isolated, you have a clear endpoint to contact and no port overlap
    checkClusterName $1
    echo "Creating new Cluster $1"
    
    # Create a new bridge network, rely on dockerd to assign a free IP range
    # Grab the IP range + the gateway (which is rechable from the host on regular docker installations)
    if [[ $(docker network list |grep $1) = "" ]]; then
        docker network create $1
    else
        echo "Docker network $1 already exists"
        return
    fi
    subnet=$(docker network inspect $1 |  jq '.[0].IPAM.Config[0].Subnet'| tr -d "\"")
    gateway=$(docker network inspect $1 |  jq '.[0].IPAM.Config[0].Gateway' |tr -d "\"")

    # Render the k3d config for the cluster with the infos we hasve
    config="/tmp/$(date +%s)config.yaml"
    cat <<EOF | tpl -f $HOME/.omz-custom/plugins/l8s/templates/cluster-template.yaml > $config
    {
      "gateway": "$gateway",
      "subnet": "$subnet",
      "name": "$1"
    }
EOF
    k3d cluster create --config $config
    if [[ ! $? -eq 0 ]]; then
        # if the cluster creation failed, we rollback the network too
        docker network rm $1
        echo "Config for debugging can be seen in $config"
        return
    fi
    rm $config

    # finally set one DNS record in your hosts file for the entire cluster
    sudo hostess add $1.local $gateway 

    # k3d is k3s which is k8s with batteries, but these batteries sometimes need tuning
    docker cp $HOME/.omz-custom/plugins/l8s/patches/traefik-patch.yaml k3d-$1-server-0:/var/lib/rancher/k3s/server/manifests/ > /dev/null

    echo "Created cluster $1 with control-plane available at $gateway:6443 and traefik (ingress-controller) at $gateway:443"
}

toolChain() {
  
  name=$(kubectl config current-context | sed 's/k3d-//g')
  echo "Current targeted cluster: $name"

  # Installation of tools must be reproducable, so that a rerun just reconfigures the tool
  case "$1" in          
    (tailscale)
      echo "Installing Tailscale to namespace tailscale"
      kubectl create namespace tailscale --dry-run=client -o yaml | kubectl apply -f - > /dev/null # idempotent
      echo "Ensure you have met the prerequisites described in https://tailscale.com/kb/1236/kubernetes-operator/#setting-up-the-kubernetes-operator"
      echo "Please enter the clientID of your OAuth app:"
      read clientID
      echo "Please enter the clientSecret of your OAuth app:"
      read clientSecret
      kubectl delete secret -n tailscale operator-oauth > /dev/null
      kubectl create secret generic operator-oauth --from-literal client_id=$clientID --from-literal client_secret=$clientSecret -n tailscale > /dev/null
      cat <<EOF | tpl -f $HOME/.omz-custom/plugins/l8s/templates/tailscale-operator-template.yaml > $(pwd)/tailscale.yaml
      {
        "name": "$name"
      }
EOF
      kubectl apply -f $(pwd)/tailscale.yaml > /dev/null
      echo "Waiting for tailscale operator to become available..."
      sleep 2
      pod=$(kubectl get pods -l "app=operator" -n tailscale -o=jsonpath='{.items[0].metadata.name}')
      kubectl wait -n tailscale --timeout=600s --for=condition=Ready pod/$pod > /dev/null 
      dnsSuffix=$(tailscale status -json | jq '.MagicDNSSuffix' | tr -d "\"")
      echo "Successfully installed Tailscale onto your cluster"
      echo "Traefik is now reachable on https://$name.$dnsSuffix, use subPaths to expose services"
      ;;
    (argocd)
      echo "Installing Argo CD to namespace argocd"
      kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f - > /dev/null # idempotent
      containsRepo=$(helm repo list |grep argo)
      if [[ $containsRepo == "" ]]
      then
          helm repo add argo https://argoproj.github.io/argo-helm
      fi
      echo "Do you want Argo CD to be exposed using tailscale or traefik?"
      read expose
      if [[ $expose == "tailscale" ]]; then
        dnsSuffix=$(tailscale status -json | jq '.MagicDNSSuffix' | tr -d "\"")
      else
        dnsSuffix="local"
      fi
      cat <<EOF | tpl -f $HOME/.omz-custom/plugins/l8s/templates/argocd-template.yaml > $(pwd)/argocd.yaml
      {
          "expose": "$expose",
          "name": "$name",
          "dnsSuffix": "$dnsSuffix"
      }
EOF
      echo "Argo CD values have been saved into your current directroy"
      helm upgrade -i -n argocd argocd argo/argo-cd -f $(pwd)/argocd.yaml > /dev/null
      echo "Waiting for Argo CD server to become available..."
      sleep 2
      pod=$(kubectl get pods -l "app.kubernetes.io/name=argocd-server" -n argocd -o=jsonpath='{.items[0].metadata.name}')
      kubectl wait -n argocd --timeout=600s --for=condition=Ready pod/$pod > /dev/null 
      kubectl wait -n argocd --for=jsonpath='{.kind}'=Secret secret/argocd-initial-admin-secret > /dev/null
      sleep 2
      echo "Argo CD UI at https://$name.$dnsSuffix/argocd using user admin and password $(getArgoAdminPW)"
      echo "Make sure you expose Dex the same way if you want to do \"Login With Dex\""
      echo "Update Argo CD using: helm upgrade -i argocd -n argocd argo/argo-cd -f ./argocd.yaml"
      ;;
    (dex)
      echo "Installing Dex to namespace dex"
      kubectl create namespace dex --dry-run=client -o yaml | kubectl apply -f - > /dev/null # idempotent 
      containsRepo=$(helm repo list |grep dex)
      if [[ $containsRepo == "" ]]
      then
        helm repo add dex https://charts.dexidp.io
      fi
      echo "Do you want Dex to be exposed using tailscale or traefik?"
      read expose
      if [[ $expose == "tailscale" ]]; then
        dnsSuffix=$(tailscale status -json | jq '.MagicDNSSuffix' | tr -d "\"")
      else
        dnsSuffix="local"
      fi
      echo "Please enter a Github Organization to use for \"Login With Dex\":"
      read org
      echo "Now head over to https://github.com/organizations/$org/settings/applications and create a new OAuth app"
      echo "Please enter the clientID of the OAuth app:"
      read clientID
      echo "Please enter the clientSecret of the OAuth app:"
      read clientSecret
      kubectl delete secret -n dex github-oauth-creds > /dev/null
      kubectl create secret generic github-oauth-creds --from-literal client_id=$clientID --from-literal client_secret=$clientSecret -n dex > /dev/null
      cat <<EOF | tpl -f $HOME/.omz-custom/plugins/l8s/templates/dex-template.yaml > $(pwd)/dex.yaml
    {
      "org": "$org",
      "dnsSuffix": "$dnsSuffix",
      "name": "$name"
    }
EOF
      echo "Dex values have been saved into your current directroy"
      helm upgrade -i -n dex dex dex/dex -f $(pwd)/dex.yaml > /dev/null
      echo "Dex successfully installed, please make sure you set the redirectURI in the OAuth App to https://$name.$dnsSuffix/dex/callback"
      ;;
    (*)
        ;;
    esac

}

#### Helper functions
checkClusterName() {
  if [[ $1 == "" ]]; then
        echo "No name for the cluster specified"
        exit 0
    fi
}

checkClusterExists() {
  clusterList=$(k3d cluster list)
  if [[ "$clusterList" != *"$1"* ]]; then
      echo "Cluster doesn't exist"
      exit 0
  fi
}

getArgoAdminPW() {
  kubectl -n argocd get secrets argocd-initial-admin-secret -o jsonpath='{.data.password}' |base64 -d
}

# https://unix.stackexchange.com/questions/55913/whats-the-easiest-way-to-find-an-unused-local-port
getRandomPort() {
    LOW_BOUND=49152
    RANGE=16384
    while true; do
        CANDIDATE=$[$LOW_BOUND + ($RANDOM % $RANGE)]
        (echo "" >/dev/tcp/127.0.0.1/${CANDIDATE}) >/dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo $CANDIDATE
            break
        fi
    done
}
