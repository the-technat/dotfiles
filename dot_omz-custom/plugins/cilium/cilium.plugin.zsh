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
  kind create cluster --config $HOME/.omz-custom/plugins/cilium/kind-config.yaml
  cilium install
  cilium hubble enable --ui --relay
  cilium status --wait
}