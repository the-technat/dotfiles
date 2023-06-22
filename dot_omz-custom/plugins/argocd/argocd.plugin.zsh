# provisions the env
# note: only one env at a time please
localArgoEnv() {
  echo "Provisioning a local argocd dev environment..."
  createK3dCluster
  telepresence helm install
  deployArgoCD
}

# cleans up the env
function destroyLocalArgoEnv() {
	k3d cluster delete argocd
  docker network rm argocd-k3d
}

function createK3dCluster() {
  sudo systemctl start docker
  name="$(date +%s)config.yaml"
  cat > /tmp/$name <<EOF
apiVersion: k3d.io/v1alpha4
kind: Simple
metadata:
  name: argocd
servers: 1
agents: 2
kubeAPI:
  hostIP: "10.123.0.1"
  hostPort: "6443"
subnet: 10.123.0.0/24
ports:
- port: 10.123.0.1:80:80
  nodeFilters:
  - loadbalancer
- port: 10.123.0.1:443:443
  nodeFilters:
  - loadbalancer
hostAliases:
  - ip: 10.123.0.1
    hostnames:
      - argocd.local
      - dex.local
EOF
  k3d cluster create --config /tmp/$name
  rm /tmp/$name
  echo "Created cluster argocd"
}

# retrieves the inital admin password from secret
function getArgoAdminPW() {
  kubectl wait -n argocd --for=jsonpath='{.kind}'=Secret secret/argocd-initial-admin-secret
  pw=$(kubectl -n argocd get secrets argocd-initial-admin-secret -o jsonpath='{.data.password}' |base64 -d)
  echo $pw
}

# setHost configures our local hosts file
function setHost() {
 host=$1
 ip=$2
 containsHost=$(cat /etc/hosts |grep $1)
  if [[ $containsHost != "" ]]
  then
    sudo sed -i "$host/d" /etc/hosts
  else
    echo "$ip $host" |sudo tee -a /etc/hosts
    source /etc/hosts > /dev/null 2>&1
  fi
}

# deployes Dex using official helm chart
# and preconfigured config this dir
# note: won't work if you omit
# clientID and clientSecret
function deployDex() {
  # pass those into the function
  id=$1
  secret=$2
  setHost dex.local 10.123.213.1
  kubectl create ns dex
  containsRepo=$(helm repo list |grep dex)
  if [[ $containsRepo == "" ]]
  then
    helm repo add dex https://chart.dexidp.io
  fi
  helm upgrade -i -n dex dex dex/dex -f $HOME/.zsh-custom/plugins/argocd/dex-values.yaml --set 'config.connectors[0].config.clientID'=$id --set 'config.connectors[0].config.clientSecret'=$secret
}

# deployes Argocd using official helm chart
# and preconfigured config from this dir
function deployArgoCD() {
  setHost argocd.local 10.123.123.1
  kubectl create ns argocd
  containsRepo=$(helm repo list |grep argo)
  if [[ $containsRepo == "" ]]
  then
    helm repo add argo https://argoproj.github.io/argo-helm
  fi
  helm upgrade -i -n argocd argocd argo/argo-cd -f $HOME/.zsh-custom/plugins/argocd/argocd-values.yaml
  echo "Waiting for Argo CD server to become available..."
  sleep 2
  pod=$(kubectl get pods -l "app.kubernetes.io/name=argocd-server" -n argocd -o=jsonpath='{.items[0].metadata.name}')
  kubectl wait -n argocd --timeout=600s --for=condition=Ready pod/$pod
  sleep 2
  echo "Argo CD UI at https://argocd.local using user admin and password $(getArgoAdminPW)"
}

# exposes an existing argocd deployment using a LB
function exposeArgoLB() {
  cat <<EOF | kubectl apply -n argocd -f -
apiVersion: v1
kind: Service
metadata:
  labels:
    app.kubernetes.io/component: server
    app.kubernetes.io/name: argocd-server
    app.kubernetes.io/part-of: argocd
  name: argocd-server-lb
  namespace: argocd
spec:
  ports:
  - port: 8080
    protocol: TCP
    targetPort: 8080
  selector:
    app.kubernetes.io/name: argocd-server
  type: LoadBalancer
EOF
}

# exposes an existing argocd deployment using an ingress
function exposeArgoIng() {
  kubectl patch -n argocd cm argocd-cmd-params-cm --patch '{"data": {"server.insecure": "true"}}'
  kubectl rollout -n argocd restart deployment argocd-server
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
}
