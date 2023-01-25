localArgoEnv() {
  echo "Provisioning a local argocd dev environment..."
  createK3dCluster
  deployDex
  deployArgoCD
}

function createK3dCluster() {
  sudo systemctl start docker
  docker network create argocd-k3d --subnet 10.123.123.0/24 --gateway 10.123.123.1
  echo "Creating local k3d argocd cluster..."
  name="$(date +%s)config.yaml"
  cat > /tmp/$name <<EOF
apiVersion: k3d.io/v1alpha4
kind: Simple
metadata:
  name: argocd
servers: 1
agents: 2
#kubeAPI:
#  hostIP: "10.123.123.1"
#  hostPort: "6445"
network: argocd-k3d
ports:
  - port: 8080:80
    nodeFilters:
      - loadbalancer
hostAliases:
  - ip: 10.123.123.1
    hostnames:
      - argocd.local
      - dex.local
EOF
  k3d cluster create --config /tmp/$name
  rm /tmp/$name
}

function deleteK3dCluster() {
	k3d cluster delete argocd
  docker network rm argocd-k3d
}

function getArgoAdminPW() {
  kubectl wait -n argocd --for=jsonpath='{.kind}'=Secret secret/argocd-initial-admin-secret 2>&1 >&- > /dev/null
  pw=$(kubectl -n argocd get secrets argocd-initial-admin-secret -o jsonpath='{.data.password}' |base64 -d)
  echo $pw
}

function getIP() {
  isArch=$(cat /etc/os-release | grep Arch)
  activeInterface=$(nmcli -g DEVICE connection show --active | head -n 1 -)
  if [[ $isArch != "" ]]
  then
    IP=$(ifconfig $activeInterface | grep inet | grep -v inet6 | awk '{print $2}' | sed 's/addr://g' -)
  else
    IP=$(ifconfig $activeInterface | grep inet | grep -v inet6 | awk '{print $2}')
  fi
  echo $IP
}

function setHost() {
 containsHost=$(cat /etc/hosts |grep $1)
  if [[ $containsHost == "" ]]
  then
    echo "$(getIP) $1" |sudo tee -a /etc/hosts
    source /etc/hosts
  else
    echo "Host already set to: $containsHost"
  fi
}

function deployDex() {
  # pass those into the function
  id=$1
  secret=$2
  setHost dex.local
  kubectl create ns dex 2>&1 >&- > /dev/null
  containsRepo=$(helm repo list |grep dex)
  if [[ $containsRepo == "" ]]
  then
    helm repo add dex https://chart.dexidp.io 2>&1 > /dev/null
  fi
  helm upgrade -i -n dex dex dex/dex -f /home/technat/.zsh-custom/plugins/argocd/dex-values.yaml --set 'config.connectors[0].config.clientID'=$id --set 'config.connectors[0].config.clientSecret'=$secret
}

function deployArgoCD() {
  setHost argocd.local
  kubectl create ns argocd 2>&1 >&- > /dev/null
  containsRepo=$(helm repo list |grep argo)
  if [[ $containsRepo == "" ]]
  then
    helm repo add argo https://argoproj.github.io/argo-helm 2>&1 > /dev/null
  fi
  helm upgrade -i -n argocd argocd argo/argo-cd -f /home/technat/.zsh-custom/plugins/argocd/argocd-values.yaml
  echo "Waiting for Argo CD server to become available..."
  sleep 2
  pod=$(kubectl get pods -l "app.kubernetes.io/name=argocd-server" -n argocd -o=jsonpath='{.items[0].metadata.name}')
  kubectl wait -n argocd --timeout=600s --for=condition=Ready pod/$pod 2>&1 >&- > /dev/null
  sleep 2
  echo "Argo CD UI at https://argocd.local using User admin and password $(getArgoAdminPW)"
}

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

function exposeArgoIng() {
  kubectl patch -n argocd cm argocd-cmd-params-cm --patch '{"data": {"server.insecure": "true"}}' 2>&1 >&- > /dev/null
  kubectl rollout -n argocd restart deployment argocd-server 2>&1 >&- > /dev/null
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
