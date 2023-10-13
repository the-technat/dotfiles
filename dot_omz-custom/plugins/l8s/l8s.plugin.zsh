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
    docker cp $HOME/.omz-custom/plugins/l8s/patches/traefik-patch.yaml k3d-$1-server-0:/var/lib/rancher/k3s/server/manifests/

    echo "Created cluster $1 with control-plane available at $gateway:6443 and traefik (ingress-controller) at $gateway:443"
}

toolChain() {
  
  name=$(kubectl config current-context | sed 's/k3d-//g')
  echo "Current targeted cluster: $name"

  # Installation of tools must be reproducable, so that a rerun just reconfigures the tool
  case "$1" in          
    (tailscale)
      echo "Installing Tailsacle to namespace tailscale"
      kubectl create namespace tailscale --dry-run=client -o yaml | kubectl apply -f - > /dev/null # idempotent
      echo "Ensure you have met the prerequisites described in https://tailscale.com/kb/1236/kubernetes-operator/#setting-up-the-kubernetes-operator"
      echo "Please enter the clientID of your OAuth app:"
      read clientID
      echo "Please enter the clientSecret of your OAuth app:"
      read clientSecret
      cat <<EOF | tpl -f $HOME/.omz-custom/plugins/l8s/templates/tailscale-operator-template.yaml > /tmp/tailscale.yaml
      {
        "client_id": "$clientID",
        "client_secret": "$clientSecret"
      }
EOF
      kubectl apply -f /tmp/tailscale.yaml -n tailscale > /dev/null
      rm /tmp/tailscale.yaml
      echo "Waiting for tailscale operator to become available..."
      sleep 2
      pod=$(kubectl get pods -l "app=operator" -n tailscale -o=jsonpath='{.items[0].metadata.name}')
      kubectl wait -n tailscale --timeout=600s --for=condition=Ready pod/$pod > /dev/null 
      ;;
    (argocd)
      echo "Installing Argo CD to namespace argocd"
        ## Argo CD
      kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f - > /dev/null # idempotent
      containsRepo=$(helm repo list |grep argo)
      if [[ $containsRepo == "" ]]
      then
          helm repo add argo https://argoproj.github.io/argo-helm
      fi
      cat <<EOF | tpl -f $HOME/.omz-custom/plugins/l8s/templates/argocd-template.yaml > $(pwd)/argocd.yaml
      {
        "argocd_url": "https://$name.local/argocd",
        "dex_url": "https://$name.local/dex"
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
      echo "Argo CD UI at https://$name.local/argocd using user admin and password $(kubectl -n argocd get secrets argocd-initial-admin-secret -o jsonpath='{.data.password}' |base64 -d)"
      echo "Update Argo CD using: helm upgrade -i argocd -n argocd argo/argo-cd -f ./argocd.yaml"
      ;;
    (dex)
      ## Dex
      echo "Installing Dex to namespace dex"
      kubectl create namespace dex --dry-run=client -o yaml | kubectl apply -f - > /dev/null # idempotent 
      containsRepo=$(helm repo list |grep dex)
      if [[ $containsRepo == "" ]]
      then
        helm repo add dex https://charts.dexidp.io
      fi
      echo "Please enter a Github Organization to use for Login With Github:"
      read org
      echo "Now head over to https://github.com/organizations/$org/settings/applications and create a new OAuth app"
      echo "Please enter the clientID of the OAuth app:"
      read clientID
      echo "Please enter the clientSecret of the OAuth app:"
      read clientSecret
      cat <<EOF | tpl -f $HOME/.omz-custom/plugins/l8s/templates/dex-template.yaml > /tmp/dex.yaml
    {
      "client_id": "$clientID",
      "client_secret": "$clientSecret",
      "org": "$org",
      "dexRedirectURI": "https://$name.local/dex/callback",
      "argoRedirectURI": "https://$name.local/argocd/auth/callback",
      "issuer": "https://$name.local/dex"
    }
EOF
      helm upgrade -i -n dex dex dex/dex -f /tmp/dex.yaml > /dev/null
      if [[ $? -eq 0 ]]; then
          rm -rf /tmp/dex.yaml
          echo "Dex successfully installed, please make sure you set the redirectURI in the OAuth App to https://$name.local/dex/callback"
      else
          echo "Dex installation failed, see /tmp/dex.yaml for values"
      fi
      ;;
    (*)
        ;;
    esac

}

enableTailscaleFunnel() {
    checkClusterName $1
    checkClusterExists $1
  
    tailscalePath=$(which tailscale)
    if [[ ! -f "$tailscalePath" ]]; then
        echo "Please install tailscale for this feature"
        echo "https://tailscale.com/kb/installation/"
        return
    fi

    tailscaleStatus=$(tailscale status)
    if [[ "$tailscaleStatus" == "Logged out." ]]; then
        echo "Tailscale must be up & running"
        echo "Use sudo tailscale up --ssh to activate"
        return
    fi

    # the funnel can only be active for one cluster at the tiem
    funnelStatus=$(tailscale funnel status)
    if [[ "$funnelStatus" == "No serve config" ]]; then
        sudo tailscale serve https $2 127.0.0.1:$3
        sudo tailscale funnel 443 on
        tailscale funnel status
    else 
        listOfActivePaths=$(tailscale funnel status --json | jq '.Web | to_entries[] | select(.key|startswith("")) | .value.Handlers | to_entries[] | .key' | tr -d "\"" | tr '\n' ' '  )
        if [[ ! ${listOfActivePaths[@]} =~ $2 ]]; then
            sudo tailscale serve https $2 127.0.0.1:$3
            echo "Funnel already active, added new subPath to the serve config"
            tailscale funnel status
        else
            echo "Funnel is currently active and the specified path is already in use"
            echo "Please active the funnel yourself"
            echo "Example: sudo tailscale serve https $2 127.0.0.1:$3"
        fi
    fi
    
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
