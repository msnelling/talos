machine:
  nodeLabels:
    topology.kubernetes.io/region: ${cluster_name}
    topology.kubernetes.io/zone: ${node_name}
  sysctls:
    net.core.rmem_max: "7500000"
    net.core.wmem_max: "7500000"
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
%{ if cilium_enabled }
  network:
    cni:
      name: none
  proxy:
    disabled: true
%{ endif }
