machine:
  nodeLabels:
    topology.kubernetes.io/region: ${cluster_name}
    topology.kubernetes.io/zone: ${node_name}
  kubelet:
    extraMounts:
      - destination: /var/lib/longhorn
        type: bind
        source: /var/lib/longhorn
        options:
          - bind
          - rshared
          - rw
cluster:
  network:
    cni:
      name: none
  proxy:
    disabled: true
