localArgoEnv() {
  sudo systemctl start docker
  echo "Provisioning a local argocd dev environment..."
  # activeInterface=$(nmcli -g DEVICE connection show --active)
  # IP=$(ifconfig $activeInterface | grep inet | grep -v inet6 | awk '{print $2}')
  echo "Creating local k3d argocd cluster..."
  k3d cluster create argocd -a 2 --api-port 0.0.0.0:6550 -p 443:443@loadbalancer -p 80:80@loadbalancer 2>&1 >&- > /dev/null
  containsRepo=$(pwd |grep argo-cd)
  if [[ $containsRepo != "" ]]
  then
    kubectl create ns argocd 2>&1 >&- > /dev/null
    kubectl apply -n argocd --force -f manifests/install.yaml 2>&1 >&- > /dev/null
  else
    echo "Not in argo-cd git repo, installing from master branch..."
    kubectl create ns argocd 2>&1 >&- > /dev/null
    kubectl apply -n argocd --force -f https://raw.githubusercontent.com/argoproj/argo-cd/master/manifests/install.yaml 2>&1 >&- > /dev/null
  fi
  echo "Waiting for Argo CD server to become available..."
  sleep 2
  pod=$(kubectl get pods -l "app.kubernetes.io/name=argocd-server" -n argocd -o=jsonpath='{.items[0].metadata.name}')
  kubectl wait -n argocd --timeout=600s --for=condition=Ready pod/$pod 2>&1 >&- > /dev/null
  sleep 2
  echo "Waiting for admin secret to be created..."
  kubectl wait -n argocd --for=jsonpath='{.kind}'=Secret secret/argocd-initial-admin-secret 2>&1 >&- > /dev/null
  pw=$(kubectl -n argocd get secrets argocd-initial-admin-secret -o jsonpath='{.data.password}' |base64 -d)
  echo "Pick an exposing method: LoadBalancer(1) Ingress(2) Telepresence(3) None()"
  read exposeMethod
  case ${exposeMethod} in
    LoadBalancer|1 )
      exposeArgoLB
      echo "Argo CD UI at https://localhost8080 using User admin and password $pw"
      ;;
    Ingress|2 )
      exposeArgoIng
      echo "Argo CD UI at https://localhost using User admin and password $pw"
      ;;
    Telepresence|3 )
      echo "Spawing new telepresence shell..."
      telepresence --swap-deployment argocd-server --namespace argocd --env-file .envrc.remote --expose 8080:8080 --expose 8083:8083 --run zsh
      export PS1="[telepresence]$PS1"
      ;;
    *)
      echo "No method, expose it on your own or port-forward to the argocd-server"
      ;;
    esac
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
      - host: localhost
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
