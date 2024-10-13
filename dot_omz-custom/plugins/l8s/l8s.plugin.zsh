# Cilium helpers scripts
unmanagedPods() {
  bash $HOME/.omz-custom/plugins/cilium/k8s-unmanaged.sh "${@}"
} 

ciliumExec() {
  bash $HOME/.omz-custom/plugins/cilium/k8s-cilium-exec.sh "${@}"
}

ciliumPod() {
  bash $HOME/.omz-custom/plugins/cilium/k8s-get-cilium-pod.sh "${@}"
}

ciliumCluster() {
  kind create cluster --config $HOME/.omz-custom/plugins/l8s/kind-profiles/cilium.yaml
  cilium install
  cilium hubble enable --ui --relay
  cilium status --wait
}

getArgoAdminPW() {
  kubectl -n argocd get secrets argocd-initial-admin-secret -o jsonpath='{.data.password}' |base64 -d
}

applyArgo() {
  if [[ $1 == "" ]]; then
    echo "Need an Argo Version"
    exit 1
  fi
  kubectl apply -f https://github.com/argoproj/argo-cd/raw/refs/tags/$1/manifests/install.yaml -n argocd              kind-argocd-1-30-2-12
}

exposeArgo() {
  kubectl -n argocd expose service argocd-server --type=LoadBalancer --name argocd-server-lb
}

argopfstart() {
  kubectl port-forward -n argocd svc/argocd-server 8080:443 & 
}

argopfstop() {
  kill $(ps | grep "argocd-server" | grep "port-forward" | cut -d ' ' -f1)
} 

kindcloud() {
  CONTAINER_NAME='cloud-provider-kind'
  ## only til https://github.com/kubernetes/k8s.io/pull/7351 is merged
  git clone https://github.com/kubernetes-sigs/cloud-provider-kind.git /tmp/cpk
  docker build /tmp/cpk -t cloud-provider-kind:local
  rm -rf /tmp/cpk
  CID=$(docker ps -q -f status=running -f name=^/${CONTAINER_NAME}$)
  if [ "${CID}" ]; then
    docker stop ${CONTAINER_NAME}
    docker rm ${CONTAINER_NAME}
  fi
  unset CID
  docker run --name cloud-provider-kind -d --rm --network kind -v /var/run/docker.sock:/var/run/docker.sock cloud-provider-kind:local
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
