localArgoEnv() {
  inGitRepo=$(git status)
  if [ $? -eq 0 ]
  then
    kubectl create ns argocd
    kubectl apply -n argocd --force -f manifests/install.yaml
    kubectl wait --for=condition=available deployment/argocd-server
    kubectl wait --for=jsonpath='{.kind}'=Secret secret/argocd-initial-admin-secret
    pw=$(kubectl -n argocd get secrets argocd-initial-admin-secret -o jsonpath='{.data.password}' |base64 -d)
    echo "Pick an expose method: LoadBalancer(1) Ingress(2)"
    read exposeMethod
    case ${exposeMethod} in
      LoadBalancer|1 )
        exposeArgoLB()
        echo "Argo CD UI at https://localhost8080 using User admin and password $pw"
        ;;
      Ingress|2 )
        exposeArgoIng()
        echo "Argo CD UI at https://localhost using User admin and password $pw"
        ;;
      *)
        echo "No valid method, expose it on your own or port-forward to the argocd-server"
        ;;
  else
    echo "Not in argo-cd git repo"
  fi
}

exposeArgoLB() {
  cat <<EOF | kubectl apply -f 
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

exposeArgoIng() {
  kubectl patch -n argocd cm argocd-cmd-params-cm --patch '{"data": {"server.insecure": "true"}}'
  kubectl rollout -n argocd restart deployment argocd-server
  cat <<EOF | kubectl apply -f -
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
