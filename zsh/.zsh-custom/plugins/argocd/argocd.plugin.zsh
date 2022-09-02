localArgoEnv() {
  inGitRepo=$(git status)
  if [ $? -eq 0 ]
  then
    kubectl create ns argocd
    kubectl apply -n argocd --force -f manifests/install.yaml
    kubectl patch -n argocd cm argocd-cmd-params-cm --patch '{"data": {"server.insecure": "true"}}'
    kubectl rollout -n argocd restart deployment argocd-server
    cat <<EOF | kubectl apply -f -
      apiVersion: networking.k8s.io/v1
      kind: Ingress
      metadata:
        name: argocd-server
        namespace: argocd
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
    kubectl wait --for=jsonpath='{.kind}'=Secret secret/argocd-initial-admin-secret
    pw=$(kubectl -n argocd get secrets argocd-initial-admin-secret -o jsonpath='{.data.password}' |base64-d)
    echo "Argo CD UI at https://localhost using User admin and password $pw"
  fi
}
