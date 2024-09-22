machine:
  nodeLabels:
    topology.kubernetes.io/region: ${cluster_name}
#    topology.kubernetes.io/zone: ${node_name}

cluster:
  network:
    cni:
      name: none
  proxy:
    disabled: true
